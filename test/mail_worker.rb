require_relative "mailer"
require "benchmark"
require "celluloid"

class MailWorker
   include Celluloid

  def send_email(id)
    Mailer.deliver do
      from    "eki_#{id}@eqbalq.com"
      to      "jill_#{id}@example.com"
      subject "Threading and Forking (#{id})"
      body    "Some content"
    end
  end
end

 mailer_pool = MailWorker.pool(size: 2)

puts Benchmark.measure{
10.times do |i|
  # mailer_pool.async.send_email(i)
  mailer_pool.async.send_email(i)
   # MailWorker.new().send_email(i)
end }
   sleep 1

# require 'celluloid'
# require 'benchmark'
#
# class Worker
#   include Celluloid
#
#   def work(i)
#     sleep(1)
#     i
#   end
# end
#
# pool = Worker.pool(:size => 10)
#
# time = Benchmark.measure do
#   f = 10.times.map{|i| pool.future(:work, i) }
#   p f.map(&:value)
# end
#
# puts time