class SekkaPath
  def self.path
    libsekka = File.dirname( __FILE__ )
    File.expand_path( libsekka + "/../.." )
  end
end
