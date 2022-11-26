// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Twitter {
  
  struct Tweet{
      uint id;
      address author;
      uint createdAt;
      string content;
  }

  struct Message{
      uint id;
      address from;
      address to;
      string content;
      uint createdAt;
  }

  mapping(uint=>Tweet) tweets;
  mapping(address=>uint[]) public tweetsOf;//tweets store
  mapping(address=>Message[]) conversation;
  mapping(address=>address[]) followers;
  mapping(address=>mapping(address=>bool)) public operators;
  
  uint nextId;
  uint nextMessageId;
 
  function tweet(address _from,string memory _content) internal {
      require(msg.sender==_from || operators[_from][msg.sender]==true,"You are not authorised");
      tweets[nextId]=Tweet(nextId,_from,block.timestamp,_content);
      tweetsOf[_from].push(nextId);
      nextId++;
  }

  function _sendMessage(string memory _content,address _from,address _to) internal{
      require(msg.sender==_from || operators[_from][msg.sender]==true,"you are not authorised ");
      conversation[_from].push(Message(nextMessageId,_from,_to,_content,block.timestamp));
      nextMessageId++;
  }

  function tweet(string calldata _content) public {
      tweet(msg.sender,_content);
  }

  function tweetFrom(address _from,string memory _content) public {
      tweet(_from,_content);
  }
  
  function _sendMessage(string memory _content,address _to) public{
      _sendMessage(_content, msg.sender, _to);
  }

  function sendMessageFrom(address _from,address _to,string memory _content) public {
      _sendMessage(_content, _from, _to);
  }

  function follow(address _followed) public{
      followers[msg.sender].push(_followed);
  }

  function allow(address _operator) public{
      operators[msg.sender][_operator]=true;
  }

  function disallow(address _operator) public{
      operators[msg.sender][_operator]=false;
  }

  function getLatestTweet(uint count) public view returns(Tweet[] memory){
      require(count>0 && count<=nextId,"Not found");
      Tweet[] memory memTweets = new Tweet[](count); //initialize an empty array of size count
      uint j;
      for(uint i=nextId-count;i<nextId;i++){//i=5;i<10;i++
          Tweet storage _tweets=tweets[i];
          memTweets[j]=Tweet(_tweets.id,_tweets.author,_tweets.createdAt,_tweets.content);
          j++;
      }
      return memTweets;
  }
  
  function getTweetsOf(address user,uint count) public view returns(Tweet[] memory){
      uint[] storage tweetsId= tweetsOf[user];
     require(count>0 && count<=tweetsOf[user].length,"Tweets not found");
      Tweet[] memory _tweets= new Tweet[](count);
      uint j;
      for(uint i=tweetsId.length-count;i<tweetsId.length;i++){
        Tweet storage _tweet=tweets[tweetsId[i]];
        _tweets[j]=Tweet(_tweet.id,_tweet.author,_tweet.createdAt,_tweet.content);
        j++;
      }
      return _tweets;
  }
  
}