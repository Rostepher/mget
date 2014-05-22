require 'thread'

class Thread::Pool
    def initialize(pool_size)
        @size = pool_size
        @mutex = Mutex.new
        @queue = Queue.new
        @pool = Array.new(@size) do |i|
            @mutex.synchronize do
                Thread.new do
                    Thread.current[:id] = i
                    loop do
                        job, args = @queue.pop
                        job.call(*args)
                    end
                end
            end
        end
    end

    # queues given block and args
    def schedule(*args, &block)
        if block.nil?
            raise ArgumentError, 'no block passed to thread'
        end
        
        @mutex.synchronize do
            @queue << [block, args]
        end
    end

    # join all threads in the pool
    def join
        @pool.each do |thread|
            thread.join unless not thread.alive?
        end
    end
end
