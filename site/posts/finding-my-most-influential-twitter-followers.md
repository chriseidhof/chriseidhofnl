---
aliases:
  - /posts/finding-my-most-influential-twitter-followers.html
date: 2012-05-29
title: Finding My Most Influential Twitter Followers
---

I spent an afternoon trying to find out who of my Twitter followers is the most
influential. I wrote the script to fetch the data in Ruby, and stored the data
in MongoDB.&#10;

**Setup**

First, we’ll need to set up some things. Make sure you have a recent version of
Ruby installed, and install the following gems:&#10;

``` 
gem install twitter mongo bson_ext
```

Although the `bson_ext` isn’t really necessary, it will make things a bit
faster.&#10;

Also install mongodb. One of the easier ways to do this is using
[homebrew](http://mxcl.github.com/homebrew/):&#10;

``` 
brew install mongodb
```

Make sure to fire up mongodb, and we’re all set on the client.&#10;

The last step is to get an API key at Twitter. Go to
[](https://dev.twitter.com/)<https://dev.twitter.com/> and create a new
application. Don’t worry about the details too much.&#10;

**Fetching a list of Twitter follower IDs**

First, we will write a file called `twitter-config.rb`:&#10;

``` 
Twitter.configure do |config|
  config.consumer_key = 'CONSUMER_KEY'
  config.consumer_secret = 'CONSUMER_SECRET'
  config.oauth_token = 'OAUTH_TOKEN'
  config.oauth_token_secret = 'O_AUTH_TOKEN_SECRET'
end
```

Make sure to replace the right-hand sides by the appropriate values (they should
match the twitter application you just created).&#10;

The script for fetching your Twitter follower ids is now extremely simple:&#10;

``` 
require 'rubygems'
require 'twitter'
require 'twitter-config.rb'

follower_ids = Twitter.follower_ids
File.open("followers", 'w') { |f| 
  f.write(follower_ids.collection.join("\n")) 
}
```

We are just using the Twitter API to fetch the follower ids and store them in a
file. The last part is essential when working with APIs and larger datasets:
make sure you store intermediate results. Often, computations can take a long
time, and by storing intermediate results you can resume where you’ve left
off.&#10;

**Write the script to fetch the data**

Again, this script is very simple. We iterate over the list of followers, and
make the corresponding Twitter API call. One thing to note here is that you will
hit the rate limit if you have more than 350 followers. Therefore, the script
checks if you already have fetched the data for a follower, and skips fetching
the data. If you hit the rate limit, simply wait some minutes and run the script
again. Eventually, it will finish.&#10;

``` 
require 'rubygems'
require 'twitter'
require 'database-config.rb'
require 'twitter-config.rb'

File.open("followers").each_line {|follower_id_s| 
  follower_id = follower_id_s.to_i

  if COLL.find("id" => follower_id).count > 0 then
    puts "Already have data for #{follower_id}"
  else
    puts "Fetching data for #{follower_id}"
    follower_hash = Twitter.user(follower_id).attrs
    COLL.insert follower_hash
  end
}
```

The `database-config.rb` file looks like this:&#10;

``` 
require 'mongo'

connection = Mongo::Connection.new
db = Mongo::Connection.new.db("twitterinsight")
COLL = db.collection("followers")
```

It sets up a global variable `COLL` that you can use in the scripts for
analyzing and populating the database.&#10;

**Analyze the data**

Once you have filled your database with data, you can analyze it by running
queries on it. The reason I wrote this code is because I wanted to know who my
most influential followers were:&#10;

``` 
require 'rubygems'
require 'database-config.rb'

COLL.find().
  sort(['followers_count', :desc]).
  limit(50).
  to_a.map { |x| 
  ratio = (100 * (x['friends_count'].to_f / 
                x['followers_count'].to_f)).to_i
  statuses = x['statuses_count']
  puts "#{x['screen_name']} - " +
       "#{x['followers_count']} / #{x['friends_count']}" +
       ", #{ratio} [#{statuses}] @ #{x['location']}" 
}
```

As you can see, this script prints the screen name, number of followers, number
of friends, the friends/followers ratio, the amount they tweet and the location.
Here’s some example output:&#10;

``` 
copumpkin - 22397 / 368, 1 [3597] @ Boston, MA
DotSauce - 15641 / 12400, 79 [7377] @ NC, USA
dominiek - 14487 / 1085, 7 [5342] @ AMS, SFO, TYO
TivoliUtrecht - 10935 / 442, 4 [3950] @ Utrecht, The Netherlands
theSeanCook - 10006 / 1137, 11 [2345] @ San Francisco
Duetschpire - 8194 / 584, 7 [2112] @ Australia
Polledemaagt - 7518 / 2563, 34 [37721] @ Gent, London, Amsterdam
NetBlueWeb - 6651 / 5520, 82 [9] @ British Columbia
andreisavu - 6648 / 6497, 97 [11496] @ Bucharest, Romania
StackMob - 5571 / 1835, 32 [1015] @ SF
```
