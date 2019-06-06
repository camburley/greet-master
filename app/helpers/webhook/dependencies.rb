require 'json'
require 'uri'

class Webhook::Dependencies
  def perspective(text)
    uri = URI.parse("https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=AIzaSyBaPBX-4VJ6o-mCzc1V43Yh4O9uDAaeGEI")
    per_request = Net::HTTP::Post.new(uri)
    per_request.content_type = "application/json"
    per_request["Cache-Control"] = "no-cache"
    per_request.body = JSON.dump({
      "comment" => {
        "text" => text
      },
      "languages" => "en",
      "requestedAttributes" => { "TOXICITY": {}, "OBSCENE": {}, "ATTACK_ON_COMMENTER": {}, "INCOHERENT": {} }
    })
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(per_request)
    end

    return JSON.parse(response.body)
  end

  def wit_data(message)
    wit_token = "XBRDACRRK6O3KNKFGWYZE6MATUI6ZK5P"

    encoded_msg = message.force_encoding('iso-8859-1')
    escaped_msg = URI.escape encoded_msg
    uri = URI.parse("https://api.wit.ai/message?v=20171120&q=#{escaped_msg}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{wit_token}"
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    return JSON.parse(response.body)
  end

  def message_tags(comment_id, token)
    uri = URI.parse("https://graph.facebook.com/v3.0/#{comment_id}?fields=message_tags&access_token=#{token}")
    response = Net::HTTP.get_response(uri)

    return JSON.parse(response.body)
  end

  def delete_message(comment_id, token)
    uri = URI.parse("https://graph.facebook.com/v3.0/#{comment_id}?access_token=#{token}")
    request = Net::HTTP::Delete.new(uri)
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  def message_regulations(message, page_id, sender_id)
    domain_block = message.match(/(\.com|\.net|\.co|\.io|\.xyz|\.chat|\.tech|\.nyc|\.org|\.go|\.ly|\.gov)/) unless page_id == sender_id

    toxic_message = message.match(/a55|a55hole|ahole|anal|analprobe|anilingus|anus|arian|aryan|ass|assbang|assbanged|assbangs|asses|assfuck|assfucker|assh0le|asshat|assho1e|assholes|assmaster|assmunch|asswipe|asswipes|azz|b1tch|ballsack|bang|beardedclam|beastiality|beatch|beater|beaver|beeyotch|beotch|biatch|bigtits|big tits|bimbo|bitch|bitched|bitches|bitchy|blow job|blow|blowjob|blowjobs|boink|bollock|bollocks|bollok|boned|boner|boners|boob|boobies|boobs|booby|bootee|bootie|booty|booze|boozer|boozy|brassiere|breast|breasts|bukkake|bullshit|bull shit|bullshits|bullshitted|bullturds|butt|butt fuck|buttfuck|buttfucker|buttfucker|buttplug|c.0.c.k|c.o.c.k.|c.u.n.t|c0ck|c-0-c-k|caca|cahone|cajone|cahones|cajones|cohon|cohone|cojone|cohones|cojones|cohon|cameltoe|carpetmuncher|cawk|chinc|chincs|chink|chink|chode|chodes|cl1t|clit|clitoris|clitorus|clits|clitty|cocain|cocaine|cock|c-o-c-k|cockblock|cockholster|cockknocker|cocks|cocksmoker|cocksucker|cock sucker|coital|commie|condom|coon|coons|corksucker|crabs|crack|cracker|crackwhore|crap|crappy|cum|cummin|cumming|cumshot|cumshots|cumslut|cumstain|cunilingus|cunnilingus|cunny|cunt|c-u-n-t|cuntface|cunthunter|cuntlick|cuntlicker|cunts|d0ng|d0uch3|d0uche|d1ck|d1ld0|d1ldo|dammit|damn|damned|damnit|dawgie-style|dick|dickbag|dickdipper|dickface|dickflipper|dickhead|dickheads|dickish|dick-ish|dickripper|dicksipper|dickweed|dickwhipper|dickzipper|diddle|dike|dildo|dildos|diligaf|dillweed|dimwit|dingle|dipship|doggie-style|doggy-style|dong|doofus|doosh|dopey|douch3|douche|douchebag|douchebags|douchey|drunk|dumass|dumbass|dumbasses|dummy|dyke|dykes|ejaculate|enlargement|erect|erection|erotic|essohbee|extacy|extasy|f.u.c.k|fack|fag|fagg|fagged|faggit|faggot|fagot|fags|faig|faigt|fannybandit|fartknocker|felch|felcher|felching|fellate|fellatio|feltch|feltcher|fisted|fisting|fisty|floozy|foad|fondle|foobar|foreskin|freex|frigg|frigga|fubar|fuck|f-u-c-k|fuckass|fucked|fucked|fucker|fuckface|fuckin|fucking|fucknugget|fucknut|fuckoff|fucks|fucktard|fuck-tard|fuckup|fuckwad|fuckwit|fudgepacker|fuk|fvck|fxck|gae|gai|ganja|gays|gey|gfy|ghay|ghey|gigolo|glans|goatse|godamn|godamnit|goddam|goddammit|goddamn|goldenshower|gonad|gonads|gook|gooks|gringo|gspot|g-spot|gtfo|guido|h0m0|h0mo|handjob|hard on|he11|hebe|heeb|hell|hemp|heroin|herp|herpes|herpy|hitler|hiv|hobag|hom0|homey|homo|homoey|honky|hooch|hooker|hoor|hootch|hooter|hooters|horny|hump|humped|humping|hussy|hymen|inbred|incest|injun|j3rk0ff|jackass|jackhole|jackoff|jap|japs|jerk|jerk0ff|jerked|jerkoff|jism|jiz|jizm|jizz|jizzed|junkie|junky|kike|kikes|kill|kinky|kkk|klan|knobend|kooch|kooches|kootch|kraut|kyke|labia|lech|leper|lesbo|lesbos|lez|lezbo|lezbos|lezzie|lezzies|lezzy|lmao|lmfao|loin|loins|lube|lusty|mams|massa|masterbate|masterbating|masterbation|masturbate|masturbating|masturbation|menses|meth|m-fucking|mofo|molest|moolie|moron|motherfucka|motherfucker|motherfucking|mtherfucker|mthrfucker|mthrfucking|muff|muffdiver|murder|muthafuckaz|muthafucker|mutherfucker|mutherfucking|muthrfucking|nad|nads|napalm|nappy|nazi|nazism|negro|nigga|niggah|niggas|niggaz|nigger|nigger|niggers|niggle|niglet|nimrod|ninny|nipple|nooky|nympho|opiate|opium|organ|orgasm|orgasmic|orgies|orgy|ovary|ovum|ovums|p.u.s.s.y.|paddy|paki|pantie|panty|pastie|pasty|pcp|pecker|pedo|pedophile|pedophilia|pedophiliac|pee|peepee|penetrate|penetration|penial|penile|penis|perversion|peyote|phalli|phallic|phuck|pillowbiter|pimp|pinko|piss|pissed|pissoff|piss-off|polack|pollock|poon|poontang|porn|porno|pornography|pot|potty|prick|prig|prostitute|prude|pube|pubic|pubis|punkass|punky|puss|pussies|pussy|pussypounder|puto|queaf|queef|queef|queer|queero|queers|quim|racy|rape|raped|raper|rapist|raunch|rectal|rectum|rectus|reefer|reetard|reich|retard|retarded|rimjob|ritard|rtard|r-tard|rum|rump|rumprammer|ruski|s.h.i.t.|s.o.b.|s0b|sadism|sadist|scag|scantily|schizo|schlong|screw|screwed|scrog|scrot|scrote|scrotum|scrud|scum|seaman|seamen|seduce|semen|sexual|sh1t|s-h-1-t|shamedame|shit|s-h-i-t|shite|shiteater|shitface|shithead|shithole|shithouse|shits|shitt|shitted|shitter|shitty|shiz|sissy|skag|skank|slave|sleaze|sleazy|slut|slutdumper|slutkiss|sluts|smegma|smut|smutty|snatch|sniper|snuff|s-o-b|sodom|souse|soused|sperm|spic|spick|spik|spiks|spooge|spunk|steamy|stfu|stiffy|stoned|strip|stroke|stupid|suck|sucked|sucking|sumofabiatch|t1t|tard|tawdry|teabagging|teat|terd|teste|testee|testes|testicle|testis|thrust|thug|tinkle|tit|titfuck|titi|tits|tittiefucker|titties|titty|tittyfuck|tittyfucker|toke|toots|tramp|transsexual|trashy|tubgirl|turd|tush|twat|twats|ugly|undies|unwed|urinal|urine|uterus|uzi|vag|valium|viagra|virgin|vixen|vodka|vomit|voyeur|vulgar|vulva|wad|wang|wank|wanker|wazoo|wedgie|weed|weenie|weewee|weiner|weirdo|wench|wetback|wh0re|wh0reface|whitey|whiz|whoralicious|whore|whorealicious|whored|whoreface|whorehopper|whorehouse|whores|whoring|wigger|woody|wop|wtf|x-rated|xxx|yeasty|yobbo|zoophile?/)

    return toxic_message ? "toxic_message" : domain_block ? "domain_block" : nil
  end
end
