require 'rubygems'
require 'tmpdir'
require 'net/ssh'
require 'net/scp'
require 'bcrypt'

class   IONISAuthentication
  @tmpDir = nil
  @lifeTime = nil
  @lstStudent = nil

  def initialize sshUserName, sshUserPass, forceUpdate = false
    @tmpDir = File.join Dir.tmpdir, 'ionis_auth/'
    @lifeTime = 3600
    @lstStudent = Hash.new
    Dir.mkdir @tmpDir if !File.directory? @tmpDir
    if !File.exist? File.join(@tmpDir, 'ppp.blowfish') or forceUpdate == true
      begin
        Net::SCP.start('ssh.epitech.eu', sshUserName, :password => sshUserPass) do |scp|
          scp.download! '/afs/epitech.net/site/etc/ppp.blowfish', @tmpDir
          scp.download! '/afs/epitech.net/site/etc/passwd', @tmpDir
          scp.download! '/afs/epitech.net/site/etc/location', @tmpDir
        end
      rescue Net::SCP::Error
        logger.info "Can't connect to ssh.epitech.eu..."
      end
    end
    
    hFile = File.new (File.join @tmpDir, 'ppp.blowfish'), 'r'
    while line = hFile.gets
      line = line.split ' '
      @lstStudent[line[0]] = Hash.new
      if line[0]
        @lstStudent[line[0]][:login]= line[0]
        @lstStudent[line[0]][:password]= line[1]
      end
    end
    hFile.close
    hFile = File.new (File.join @tmpDir, 'passwd'), 'r'
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
    hFile = File.new (File.join @tmpDir, 'location'), 'r'
    while line = hFile.gets
      line = line.split ':'
      if @lstStudent[line[0]]
        @lstStudent[line[0]][:city] = line[1].strip
      end
    end
    hFile.close
  end

  def chkPass userName, userPass
    false if @lstStudent == nil
    return @lstStudent[userName] if BCrypt::Engine.hash_secret(userPass , @lstStudent[userName][:password]) == @lstStudent[userName][:password]
    false
  end

  def getUser userName
    false if @lstStudent == nil
    return @lstStudent[userName]
  end
end
