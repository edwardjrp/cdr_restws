require "rubygems"
require "bundler/setup"
Bundler.require
require "sinatra"
require "i18n"
require "active_record"
require File.expand_path('../db.rb', __FILE__)
require File.expand_path('../ws_dbobjets.rb', __FILE__)


class CdrWs < Sinatra::Application #Only apply to production deployment as a rackup app, for dev purposes is a direct app not a class, allows easier testing

get "/" do
  "<h2>Asterisk VoIP bases CallCenter CDR REST WebService....</h2>"
end

get "/totalincoming" do
  "Total Incoming Call Per Date Range..."
end

get "/totalincoming.json" do
  content_type :json
  {"params" => params}.to_json

  fecha1 = params[:fecha1].to_s.strip
  fecha2 = params[:fecha2].to_s.strip
  token = params[:token].to_s.strip
  nonce = params[:nonce].to_s.strip
  cedula = ""

  result = gettotalincoming(fecha1, fecha2, cedula, token, nonce)
  #"result: "+result.inspect+"fecha1: "+fecha1+" - fecha2: "+fecha2+" - token: "+token+" - nonce: "+nonce
  result.to_json

end


def gettotalincoming(fecha1, fecha2, cedula, token, nonce)
  result = checktoken(fecha1, fecha2,cedula, token, nonce)
  resulttotal = Hash.new
  if result[:resultcode] == 3
    return result
  else
    #cdr = Cdr.new
    totalcalls = Cdr.count(:conditions => "date(calldate) between '#{fecha1}' and '#{fecha2}' and dstchannel like 'Agent/%' and billsec > 0 and disposition = 'ANSWERED' ")

    wslog = WsLogs.new
    wslog.username = result[:username]
    wslog.nonce = nonce
    wslog.authtoken = token
    wslog.fecha1 = fecha1
    wslog.fecha2 = fecha2
    wslog.cedula = cedula
    wslog.modulo = 1
    wslog.result = 0
    wslog.save

    resulttotal[:resultcode] = 0
    totalhash = Hash.new
    totalhash[:totalincoming] = totalcalls
    resulttotal[:result] = totalhash

    return resulttotal

  end

end


get "/totalincoming_agent" do
  "Total Incoming Calls Per Date Range Per Agent..."
end

get "/totalincoming_agent.json" do
  content_type :json
  {"params" => params}.to_json

  fecha1 = params[:fecha1].to_s.strip
  fecha2 = params[:fecha2].to_s.strip
  cedula = params[:cedula].to_s.strip
  token = params[:token].to_s.strip
  nonce = params[:nonce].to_s.strip

  result = gettotalincoming_agent(fecha1, fecha2, cedula, token, nonce)
  #"result: "+result.inspect+"fecha1: "+fecha1+" - fecha2: "+fecha2+" - token: "+token+" - nonce: "+nonce
  result.to_json

end


def gettotalincoming_agent(fecha1, fecha2, cedula, token, nonce)
  result = checktoken(fecha1, fecha2, cedula, token, nonce)
  resulttotal = Hash.new
  if result[:resultcode] == 3
    return result
  else
    totalcalls = Cdr.count(:conditions => "date(calldate) between '#{fecha1}' and '#{fecha2}' and dstchannel like 'Agent/#{cedula}' and billsec > 0 and disposition = 'ANSWERED' ")

    wslog = WsLogs.new
    wslog.username = result[:username]
    wslog.nonce = nonce
    wslog.authtoken = token
    wslog.fecha1 = fecha1
    wslog.fecha2 = fecha2
    wslog.cedula = cedula
    wslog.modulo = 2
    wslog.result = 0
    wslog.save

    resulttotal[:resultcode] = 0
    totalhash = Hash.new
    totalhash[:cedula] = cedula
    totalhash[:totalincoming_agent] = totalcalls
    resulttotal[:result] = totalhash

    return resulttotal

  end

end


get "/detailincoming" do
  "Incoming Calls Detail Per Date Range..."
end

get "/detailincoming.json" do
  content_type :json
  {"params" => params}.to_json

  fecha1 = params[:fecha1].to_s.strip
  fecha2 = params[:fecha2].to_s.strip
  cedula = ""
  token = params[:token].to_s.strip
  nonce = params[:nonce].to_s.strip

  result = getdetailincoming(fecha1, fecha2, cedula, token, nonce)
  #"result: "+result.inspect+"fecha1: "+fecha1+" - fecha2: "+fecha2+" - token: "+token+" - nonce: "+nonce
  result.to_json

end

def getdetailincoming(fecha1, fecha2, cedula, token, nonce)
  result = checktoken(fecha1, fecha2, cedula, token, nonce)
  resulttotal = Hash.new
  if result[:resultcode] == 3
    return result
  else
    @detail = Cdr.select("src as callid,calldate,substring(dstchannel,7) as agent,billsec as durationinseconds").where("date(calldate) between '#{fecha1}' and '#{fecha2}' and dstchannel like 'Agent/%' and billsec > 0  and disposition = 'ANSWERED' ")

    wslog = WsLogs.new
    wslog.username = result[:username]
    wslog.nonce = nonce
    wslog.authtoken = token
    wslog.fecha1 = fecha1
    wslog.fecha2 = fecha2
    wslog.cedula = cedula
    wslog.modulo = 3
    wslog.result = 0
    wslog.save

    resulttotal[:resultcode] = 0
    resulttotal[:totalcalls] = @detail.size
    resulttotal[:result] = @detail
    return resulttotal

  end

end

get "/detailincoming_agent" do
  "Incoming Calls Detail Per Date Range Per Agent..."
end

get "/detailincoming_agent.json" do
  content_type :json
  {"params" => params}.to_json

  fecha1 = params[:fecha1].to_s.strip
  fecha2 = params[:fecha2].to_s.strip
  cedula = params[:cedula].to_s.strip
  token = params[:token].to_s.strip
  nonce = params[:nonce].to_s.strip

  result = getdetailincoming_agent(fecha1, fecha2, cedula, token, nonce)
  #"result: "+result.inspect+"fecha1: "+fecha1+" - fecha2: "+fecha2+" - token: "+token+" - nonce: "+nonce
  result.to_json

end

def getdetailincoming_agent(fecha1, fecha2, cedula, token, nonce)
  result = checktoken(fecha1, fecha2, cedula, token, nonce)
  resulttotal = Hash.new
  if result[:resultcode] == 3
    return result
  else
    @detail = Cdr.select("src as callid,calldate,billsec as durationinseconds").where("date(calldate) between '#{fecha1}' and '#{fecha2}' and dstchannel like 'Agent/#{cedula}' and billsec > 0  and disposition = 'ANSWERED' ")

    wslog = WsLogs.new
    wslog.username = result[:username]
    wslog.nonce = nonce
    wslog.authtoken = token
    wslog.fecha1 = fecha1
    wslog.fecha2 = fecha2
    wslog.cedula = cedula
    wslog.modulo = 4
    wslog.result = 0
    wslog.save

    resulttotal[:resultcode] = 0
    resulttotal[:totalcalls] = @detail.size
    resulttotal[:result] = @detail
    return resulttotal

  end

end


get "/callsbyhour" do
  "Total Incoming Calls By Hour Per Date Range..."
end

get "/callsbyhour.json" do
  content_type :json
  {"params" => params}.to_json

  fecha1 = params[:fecha1].to_s.strip
  fecha2 = params[:fecha2].to_s.strip
  cedula = ""
  token = params[:token].to_s.strip
  nonce = params[:nonce].to_s.strip

  result = getcallsbyhour(fecha1, fecha2, cedula, token, nonce)
  #"result: "+result.inspect+"fecha1: "+fecha1+" - fecha2: "+fecha2+" - token: "+token+" - nonce: "+nonce
  result.to_json

end

def getcallsbyhour(fecha1, fecha2, cedula, token, nonce)
  result = checktoken(fecha1, fecha2, cedula, token, nonce)
  resulttotal = Hash.new
  if result[:resultcode] == 3
    return result
  else
    @detail = Cdr.select("date(calldate) as calldate,hour(time(calldate)) as callhour,count(*) as totalcalls").where("date(calldate) between '#{fecha1}' and '#{fecha2}' and dstchannel like 'Agent/%' and billsec > 0  and disposition = 'ANSWERED' ").group("date(calldate), hour(time(calldate))").order("date(calldate)")

    wslog = WsLogs.new
    wslog.username = result[:username]
    wslog.nonce = nonce
    wslog.authtoken = token
    wslog.fecha1 = fecha1
    wslog.fecha2 = fecha2
    wslog.cedula = cedula
    wslog.modulo = 5
    wslog.result = 0
    wslog.save

    incoming = Hash.new
    hourhash = Hash.new
    previousdate = nil
    @detail.each do |r|
      date = r['calldate'].to_s
      hour = r['callhour'].to_s
      total = r['totalcalls'].to_s

      if previousdate != date
        hourhash = {}
      end

      hourhash[hour] = total
      incoming[date] = hourhash
      previousdate = date
    end

    resulttotal[:resultcode] = 0
    resulttotal[:result] = incoming
    return resulttotal

  end

end

get "/agentsbyhour" do
  "Average Agents By Hour Per Date Range..."
end

get "/agentsbyhour.json" do
  content_type :json
  {"params" => params}.to_json

  fecha1 = params[:fecha1].to_s.strip
  fecha2 = params[:fecha2].to_s.strip
  cedula = ""
  token = params[:token].to_s.strip
  nonce = params[:nonce].to_s.strip

  result = getagentsbyhour(fecha1, fecha2, cedula, token, nonce)
  #"result: "+result.inspect+"fecha1: "+fecha1+" - fecha2: "+fecha2+" - token: "+token+" - nonce: "+nonce
  result.to_json

end

def getagentsbyhour(fecha1, fecha2, cedula, token, nonce)
  result = checktoken(fecha1, fecha2, cedula, token, nonce)
  resulttotal = Hash.new
  if result[:resultcode] == 3
    return result
  else
    @detail = AgentsCount.select("date(datetime) as date,hour(time(datetime)) as hour,avg(cantidad) as avgagents").where("date(datetime) between '#{fecha1}' and '#{fecha2}' ").group("date(datetime), hour(time(datetime))").order("date(datetime)")

    wslog = WsLogs.new
    wslog.username = result[:username]
    wslog.nonce = nonce
    wslog.authtoken = token
    wslog.fecha1 = fecha1
    wslog.fecha2 = fecha2
    wslog.cedula = cedula
    wslog.modulo = 6
    wslog.result = 0
    wslog.save

    incoming = Hash.new
    hourhash = Hash.new
    previousdate = nil
    @detail.each do |r|
      date = r['date'].to_s
      hour = r['hour'].to_s
      total = r['avgagents'].to_s

      if previousdate != date
        hourhash = {}
      end

      hourhash[hour] = total
      incoming[date] = hourhash
      previousdate = date
    end

    resulttotal[:resultcode] = 0
    resulttotal[:result] = incoming
    return resulttotal

  end

end


def checktoken(fecha1, fecha2,cedula, token, nonce)
  user = WsUsers.where("md5(concat(username,':',:nonce,':',password)) = :token",{:nonce => nonce, :token => token}).first
  result = Hash.new
  if !user.nil?
    result[:id] = user.id
    result[:username] = user.username
    return result
  else

    wslog = WsLogs.new
    wslog.username = "<BAD-AUTH>"
    wslog.nonce = nonce
    wslog.authtoken = token
    wslog.fecha1 = fecha1
    wslog.fecha2 = fecha2
    wslog.cedula = cedula
    wslog.modulo = 1
    wslog.result = 3
    wslog.save

    result[:resultcode] = 3
    result[:result] = "Bad authentication token"
    #log = DbUtils.new
    #log.loginfomessage "RESULTCODE => "+result[:resultcode].to_s
    return result
  end

end


end



