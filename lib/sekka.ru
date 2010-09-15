require './lib/sekkaserver'

#dictSource = "localhost:11211" # memcahced
dictSource = "localhost:21201" # memcachedb
#dictSource = "./data/SEKKA-JISYO.L.201008"

run SekkaServer.new( dictSource )
