module IONIS
  module Exception
    class Exception < ::RuntimeError
      attr_reader :code, :reason
      
      def initialize(code, reason)
        @code, @reason = code, reason
        super "#{reason} (#{code})"
      end
    end
    class BadAuthentication < Exception; end
    class HostNotFound < Exception; end
    class ConnectionRefused < Exception; end
    class FileGrabber < Exception; end
  end
end
