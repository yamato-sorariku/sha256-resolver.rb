require 'digest/sha2'

hash = ARGV[0]

worker = 16
window_size = 100000
i = 0

while true
  run_worker = worker - 1
  (1...worker).each { |_|
    _start = i
    _end = i + window_size
    i = i + window_size + 1
    fork do
      (_start..._end).each { |_i|
        input = _i.to_s(16)
        if Digest::SHA256.hexdigest(input) == hash
          printf "resolved! result is %s\n", input
          Process.exit 0
          break
        end
      }
      Process.exit 1
    end
  }

  while true
    break if run_worker.zero?
    begin
      result = Process.waitpid2
      run_worker = run_worker - 1
      Process.exit 0 if result[1].success?
      sleep 0.01
    rescue Errno::ECHILD
      # ignore (無限ループする危険あるけど一旦これで)
    end
  end
end