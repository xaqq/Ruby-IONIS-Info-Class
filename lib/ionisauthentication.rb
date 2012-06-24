require 'rubygems'
require 'tmpdir'
require 'net/ssh'
require 'net/scp'
require 'bcrypt'
require 'ionisexceptions'

module  IONIS
  class   Authentication
    @tmpDir = nil
    @lstStudent = nil

	# Instance of Authentication - sshUserName and sshUserPass are needed to update IONIS Auth. file from IONIS Server.
	# @param [String] sshUserName IONIS Login
	# @param [String] sshUserPass Unix password
	# @param [Boolean] forceUpdate Force update of IONIS Auth. files
	# @return [Authentication] A new instance of Authentication
    def initialize sshUserName, sshUserPass, forceUpdate = false
      @tmpDir = File.join Dir.tmpdir, 'ionis_auth/'
      @lstStudent = Hash.new
      Dir.mkdir @tmpDir if !File.directory? @tmpDir
      if !File.exist? File.join(@tmpDir, 'ppp.blowfish') or forceUpdate == true
        begin
          Net::SCP.start('ssh.epitech.eu', sshUserName, :password => sshUserPass) do |scp|
            scp.download! '/afs/epitech.net/site/etc/ppp.blowfish', @tmpDir
            scp.download! '/afs/epitech.net/site/etc/passwd', @tmpDir
            scp.download! '/afs/epitech.net/site/etc/location', @tmpDir
          end
        rescue SocketError
          raise IONIS::Exception::HostNotFound.new 405, "Can't resolve ssh.epitech.eu"
        rescue Errno::ECONNREFUSED
          raise IONIS::Exception::ConnectionRefused.new 403, "Connection refused to ssh.epitech.eu"
        rescue Net::SSH::AuthenticationFailed
          raise IONIS::Exception::BadAuthentication.new 402, "Bad authentication"
        rescue Net::SCP::Error
          raise IONIS::Exception::FileGrabber.new 404, "Can't copy file from ssh.epitech.eu..."
        end
      end

      hFile = File.new ((File.join @tmpDir, 'ppp.blowfish'), 'r')
      while line = hFile.gets
        line = line.split ' '
        @lstStudent[line[0]] = Hash.new
        if line[0]
          @lstStudent[line[0]][:login]= line[0]
          @lstStudent[line[0]][:password]= line[1]
          @lstStudent[line[0]][:picture]= "http://www.epitech.eu/intra/picture/#{line[0]}.jpg"
        end
      end
      hFile.close
      hFile = File.new ((File.join @tmpDir, 'passwd'), 'r')
      while line = hFile.gets
        line = line.split ':'
        if @lstStudent[line[0]]
          @lstStudent[line[0]][:uid] = line[2]
          @lstStudent[line[0]][:gid] = line[3]
          if line[4].length > 0
            line[4] = line[4].split ' '
            line[4][0].capitalize!
            line[4][1].upcase!
            @lstStudent[line[0]][:fullname] = "#{line[4][0]} #{line[4][1]}"
          end
        end
      end
      hFile.close
      hFile = File.new ((File.join @tmpDir, 'location'), 'r')
      while line = hFile.gets
        line = line.split ':'
        if @lstStudent[line[0]]
          @lstStudent[line[0]][:city] = line[1].strip
        end
      end
      hFile.close
    end

	# Check PPP Password of given user
	# @param [String] userName IONIS Login
	# @param [String] userPass PPP Password
	# @return [Mixed] Informations about given user in Array if password if correct. Otherwize: false
    def chkPass userName, userPass
      false if @lstStudent == nil
      return @lstStudent[userName] if BCrypt::Engine.hash_secret(userPass , @lstStudent[userName][:password]) == @lstStudent[userName][:password]
      false
    end

	# Get informations about one user
	# @param [String] userName IONIS Login
	# @return [Hash] Information about given user in Array. If User doesn't exist, the returned array will be empty
    def getUser userName
      false if @lstStudent == nil
      return @lstStudent[userName]
    end
  end
end
