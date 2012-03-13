require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'bcrypt'

class   IONISAuthentication
  @tmpDir = nil
  @lifeTime = nil
  @lstStudent = nil

  def initialize sshUserName, sshUserPass, forceUpdate = false
    @tmpDir = '/tmp/ionis_auth/'
    @lifeTime = 3600
    @lstStudent = Hash.new("Go Fish")
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
      @lstStudent[line[0]] = { :password => line[1] }
    end
    hFile.close
  end

  def chkPass userName, userPass
    false if @lstStudent == nil
    return true if BCrypt::Engine.hash_secret(userPass , @lstStudent[userName][:password]) == @lstStudent[userName][:password]
    false
  end

  def getPromo userName
    false if @lstStudent == nil
  end

  def getSchool userName
    false if @lstStudent == nil
  end

  def getGroup userName
    false if @lstStudent == nil
  end

end
