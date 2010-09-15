require './lib/sekkaserver'

#dictSource = "localhost:11211" # memcahced
#dictSource = "localhost:21201" # memcachedb
dictSource = "./data/SEKKA-JISYO.L.201008.kct"
#dictSource = "./data/SEKKA-JISYO.S.201001.kct"

cacheSource = "localhost:11211" # memcahced
#cacheSource = false

run SekkaServer.new( dictSource, cacheSource )
