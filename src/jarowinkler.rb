module JaroWinkler
  
  def self.distance(str1, str2)
    str1.strip!
    str2.strip!

    if str1 == str2
      return 1
    end

    # str2 should be the longer string
    if str1.length > str2.length
      tmp = str2
      str2 = str1
      str1 = tmp
    end

    lmax = str2.length

    # arrays to keep track of positions of matches
    found1 = Array.new(str1.length, false)
    found2 = Array.new(str2.length, false)

    midpoint = ((str1.length / 2) - 1).to_i

    common = 0

    for i in 0..str1.length
      first = 0
      last = 0
      if midpoint >= i
        first = 1
        last = i + midpoint
      else
        first = i - midpoint
        last = i + midpoint
      end

      last = lmax if last > lmax

      for j in first..last
        if str2[j] == str1[i] and found2[j] == false
          common += 1
          found1[i] = true
          found2[j] = true
          break
        end
      end
    end

    last_match = 1
    tr = 0
    for i in 0..found1.length
      if found1[i]
        for j in (last_match..found2.length)
          if found2[j]
            last_match = j + 1
            tr += 0.5 if str1[i] != str2[j]
          end
        end
      end
    end

    onethird = 1.0/3
    if common > 0
      return [(onethird * common / str1.length) +
              (onethird * common / str2.length) +
              (onethird * (common - tr) / common), 1].min
    else
      return 0
    end
  end

end
