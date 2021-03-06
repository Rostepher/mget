#
# Based heavily on Rake::ThreadPool and Rake::Promise
#

require 'thread'
require 'set'

module MangaGet
    class ThreadPool
        # Encapsulates a block and arguments to be run by a thread.
        class Task
            # unique value to express variable is not set
            NOT_SET = Object.new.freeze

            def initialize(args, &block)
                @mutex = Mutex.new
                @result = NOT_SET
                @error = NOT_SET
                @args = args
                @block = block
            end

            # Will immediately return a value if there is a result, otherwise
            # it will start the task and wait for execution to end.
            def value
                unless complete?
                    @mutex.synchronize do
                        start
                    end
                end
                error? ? raise(@error) : @result
            end

            # If no other thread is working on the task, begin execution.
            def start
                if @mutex.try_lock
                    call_block
                    @mutex.unlock
                end 
            end

            private
            
            # Calls the block and saves the result or error if an exception was
            # caught.
            def call_block
                return if complete?
                
                begin
                    @result = @block.call(*@args)
                rescue Exception => e
                    @error = e
                end
                discard
            end

            # Is there a result?
            def result?
                !@result.equal?(NOT_SET)
            end

            # Did execution throw an error?
            def error?
                !@error.equal?(NOT_SET)
            end

            # Is the task complete?
            def complete?
                result? || error?
            end

            # Discards the values of args and block
            def discard
                @args = nil
                @block = nil
            end
        end

        def initialize(pool_size)
            @max_active_threads = pool_size.abs
            @threads = Set.new
            @queue = Queue.new
            @mutex = Mutex.new
            @join_cond = ConditionVariable.new
        end

        # Moves the given block and args onto the queue in a new Task object.
        def schedule(*args, &block)
            task = Task.new(args, &block)
            @queue.enq(task)
            start_thread
            task
        end

        # Joins all running threads with tasks until the thread pool is empty.
        def join
            @mutex.synchronize do
                # tell join condition to wait until pool is empty
                @join_cond.wait(@mutex) unless @threads.empty?
            end
        end

        private

        # Processes next item on the queue. Returns true if there was an
        # item to process, false if there was no item
        def process_queue_next
            return false if @queue.empty?

            # Even though we just asked if the queue was empty, it
            # still could have had an item which by this statement
            # is now gone. For this reason we pass true to Queue#deq
            # because we will sleep indefinitely if it is empty.
            task = @queue.deq(true)
            task.start
            return true

            rescue ThreadError # this means the queue is empty
            false
        end

        # A thread safe method to access the thread count.
        def safe_thread_count
            @mutex.synchronize do
                @threads.count
            end
        end

        # Starts a thread if the current number of threads is not at the max,
        # and passes the thread a block to run the next task from the queue and
        # once the task is complete, remove itself from the set of threads.
        def start_thread
            @mutex.synchronize do
                next unless @threads.count < @max_active_threads
            
                t = Thread.new do
                    begin
                        while safe_thread_count <= @max_active_threads
                            break unless process_queue_next
                        end
                    ensure
                        @mutex.synchronize do
                            # remove used thread from pool
                            @threads.delete Thread.current
                            @join_cond.broadcast if @threads.empty?
                        end
                    end
                end

                @threads << t
            end
        end
    end
end
