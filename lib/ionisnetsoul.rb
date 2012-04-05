require 'rubygems'
require 'socket'
require 'tmpdir'
require 'ionisexceptions'

module IONIS
  class Netsoul
    @tmpDir = nil
    @usrData = nil

	# Instance of Netsoul
	# @return [Netsoul] A new instance of Netsoul
    def initialize
      @tmpDir = File.join Dir.tmpdir, 'ionis_auth'
      Dir.mkdir @tmpDir if !File.directory? @tmpDir
      @tmpDir = File.join Dir.tmpdir, 'ionis_auth/nsUser'
      if !File.exist? @tmpDir or (File.mtime(@tmpDir).to_i + 300) < Time.now.to_i 
        begin
          hSock = TCPSocket.open('ns-server.epita.fr', 4242)
          line = hSock.gets
          if /salut (.*)/.match(line)
            hSock.write "list_users\n"
            @usrData = Hash.new
            while line = hSock.gets
              line.strip!
              break if line == 'rep 002 -- cmd end'
              line = line.split ' '
              @usrData[line[1]] = Hash.new
              @usrData[line[1]]['login'] = line[1]
              @usrData[line[1]]['ip'] = line[2]
              line[10] = line[10].split ':'
              @usrData[line[1]]['state'] = line[10][0]
              @usrData[line[1]]['since'] = line[10][1]
            end
          end
          hSock.close
        rescue SocketError
          raise IONIS::Exception::HostNotFound.new 405, "Can't resolve ns-server.epita.fr"
        rescue Errno::ECONNREFUSED
          raise IONIS::Exception::ConnectionRefused.new 403, "Connection refused to ns-server.epita.fr"
        end
        File.open(@tmpDir, "wb") {|f| Marshal.dump(@usrData, f)}
      else
        @usrData =  File.open(@tmpDir, "rb") {|f| Marshal.load(f)}
      end
    end

	# Get informations about given connected user
	# @param [String] login IONIS Login
	# @return [Hash] Information about given user in Array. If User doesn't exist, the returned array will be empty
    def getUser login
      return false if !@usrData
      @usrData[login]
    end

	# Get number of connected user(s)
	# @return [fixnum] Number of connected user(s)
    def size
      return @usrData.size
    end

	# Get informations about all connected user
	# @return [Hash] Information about given user in Array. If no-one was connected, the returned array will be empty
    def getAllOnlineUsers
      return false if !@usrData
      @usrData[login]
    end

	# Check if user is connected
	# @param [String] login IONIS Login
	# @return [Boolean] True if user is Online, otherwize: false
    def online? login
      return false if !@usrData
      return true if @usrData[login]
      false
    end
  end
end
