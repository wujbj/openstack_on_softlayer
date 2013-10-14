#/******************************************************* {COPYRIGHT} ***
# * Licensed Materials - Property of IBM
# *
# * 5725-C88
# *
# * (C) Copyright IBM Corp. 2012, 2013 All Rights Reserved
# *
# * US Government Users Restricted Rights - Use, duplication or
# * disclosure restricted by GSA ADP Schedule Contract with
# * IBM Corp.
#******************************************************* {COPYRIGHT} ***/


require 'net/http'  
  
module UpgradeCouchDB 
  class CouchServer 

    def initialize(host,port,options = nil)  
      @host=host  
      @port=port  
      @options=options  
    end  
    
    def put(uri,json)  
      req = Net::HTTP::Put.new(uri)  
      req["content-type"] = "application/json"   
      req.body = json  
      request(req)  
    end  

    def post(uri,json)
      req = Net::HTTP::Post.new(uri)  
      req["content-type"] = "application/json"   
      req.body = json  
      request(req)  
    end 
      
    def get(uri)  
      request(Net::HTTP::Get.new(uri))  
    end  
      
    def delete(uri)  
      request(Net::HTTP::Delete.new(uri))  
    end  
          
    def request(req)  
      res = Net::HTTP.start(@host,@port){|http| http.request(req)}  
      unless res.kind_of?(Net::HTTPSuccess){  
           handle_error(req,res)  
       }  
      end  
      res.body   
    end  
      
    private  
    def handle_error(req,res)  
      e = RuntimeError.new("#{res.code}:#{res.message}\n METHOD:#{req.method}\nURI:#{req.uri}\n#{req.body}")  
      raise e        
    end
  end
end
