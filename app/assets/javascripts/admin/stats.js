var export_json;

$(function(){
  let page_id;
  const pages_widget = $('.page-widget'),
        pages = pages_widget.find('li'),
        page_selected = $('.page-selected'),
        dataPlatform = $('.platform-menu').find('li');

  $('#export_csv').click(function(){
    var period = $('.data-menu select').find(':selected').val();
    downloadCSV(period);
  });

  $('.data-menu select').change(function(){
    var period = $(this).find(':selected').val();
    getData(page_id, period, getPlatform());
  });

  // SELECTIG PAGES
  let first_page = pages.first();
  page_selected.html(first_page.html())
               .click(function(){
                 pages_widget.toggle();
               });

  c_page_id = Cookies.get('pid');
  page_id = (c_page_id) ? c_page_id : first_page.find('input').val();

  if (c_page_id !== undefined) {
    const c_page = pages.find('input[value="'+ c_page_id +'"]');
    page_selected.html(c_page.parent('.page').html());
  }

  getData(page_id, $('.data-menu select').find(':selected').val(), getPlatform());

  // GET NEW DATA ON CHANGE

  pages.click(function(){
    $('.echo-data').fadeOut();
    page_id = $(this).find('input').val();

    page_selected.html($(this).html());
    pages_widget.hide();

    Cookies.set('pid', page_id, { expires: 7 });
    getData(page_id, $('.data-menu select').find(':selected').val(), getPlatform());
  });

  dataPlatform.click(function(){
    dataPlatform.removeClass('active');
    $(this).addClass('active');

    getData(page_id, $('.data-menu select').find(':selected').val(), getPlatform());
  })

  $(document).mouseup(function(e) {
    if (!pages_widget.is(e.target) && pages_widget.has(e.target).length === 0) {
      pages_widget.hide();
    }
  });
});

// GET PLATFORM
function getPlatform(){
  const dataPlatform = $('.platform-menu');
  return dataPlatform.find('li.active').data('platform');
}

// GET POST DATA
function getData(page_id, period, platform) {
  $.getJSON({
    url: "/api/v1/page/"+ page_id,
    data: { period: period, platform: platform },
    dataType: "json",
    success: function(data){
      var echo_data = $('.echo-data');
      var echo_data_per = $('.echo-data-per-post');
      echo_data.html('');
      echo_data_per.html('');

      export_json = data;
      var date = setDatePeriod(period);

      $.each(data, function(k,v){
        if(v.hasOwnProperty('total')){
          echo_data.append('<div class="echo" data-key="'+ k +'">'+
                            '<p class="title">'+ v["title"] +'</p>'+
                            '<p class="date">'+ date +'</p>'+
                            '<div class="data">'+
                              '<span class="count" id="main">'+ (v["total"] || 0) +'</span>'+
                            '</div>'+
                            '<p class="desc">'+ v["desc"] +'</p>'+
                            '<span class="sparkline" id="'+ k +'"></span>'+
                          '</div>');
        }

        // if (v.hasOwnProperty('per_post')) {
        //   echo_data_per.append('<div class="echo">'+
        //                     '<p class="title">'+ v["title"] +'</p>'+
        //                     '<p class="date">'+ date +'</p>'+
        //                     '<div class="data">'+
        //                       '<span id="main" id="'+ k +'">'+ (v["per_post"] || 0) +'</span>'+
        //                     '</div>'+
        //                     '<p class="desc">'+ v["desc"] +' | Per Post</p>'+
        //                   '</div>');
        // }
      });

      $('.count').each(function () {
          $(this).prop('Counter',0).animate({
              Counter: $(this).text()
          }, {
              duration: 2500,
              easing: 'swing',
              step: function (now) {
                  $(this).text(Math.ceil(now));
              }
          });
      });

      $.getJSON({
        url: "/api/v1/graph/"+ page_id,
        data: { insights: "page", period: period, platform: platform },
        dataType: "json",
        success: function(data){
          drawGraph(data);
        }
      });

      // OPEN MODAL GET INTENTS
      $('.echo-data').find('.echo').click(function(){
        var key = $(this).data('key');
        getIntentData(page_id, period, platform, key);

        $('.modal-close').click(function(){
          $('.modal-data').fadeOut();
        });
      });

      $('.echo-data').fadeIn();
    }
  });

  return false;
}

// GET INTENTS FOR DATA
function getIntentData(page_id, period, platform, key) {
  var modal_date = $('.modal-data').find('select');
  modal_date.val(period);

  $.getJSON({
    url: "/api/v1/intents/"+ page_id +"/"+ key,
    data: { period: period, platform },
    dataType: "json",
    success: function(data, message, code){
      var list = $('.modal-content .intents').find('.list');
      list.html('');

      if(code.status === 200){
        $.each(data, function(k,v){
          list.append('<li class="intent" data-intent="'+ k +'"><p>'+ k.replace(/_/g, ' ') +'</p><span>'+ v +'</span></li>');
        });

        var first_intent = list.find('li:first-child');
        first_intent.addClass('active');
        getMessageData(page_id, period, platform, key, first_intent.data('intent'));

        $('.intent').click(function(e){
          e.stopImmediatePropagation();

          $('.intent').removeClass('active');
          $(this).addClass('active');
          getMessageData(page_id, period, platform, key, $(this).data('intent'));
        });
      } else {
        $('.messages').html('<h1 class="alert">No Content!</h1>');
      }

      $('.modal-data').fadeIn();
    }
  });

  modal_date.change(function(e){
    e.stopImmediatePropagation();

    var period = $(this).find(':selected').val();
    getIntentData(page_id, period, platform, key);
  });

  return false;
};

// GET MESSAGES FOR INTENT
function getMessageData(page_id, period, platform, key, intent) {

  $.getJSON({
    url: "/api/v1/messages/"+ page_id +"/"+ key +"/"+ intent,
    data: { period: period, platform: platform },
    dataType: "json",
    success: function(data){
      var messages = $('.messages');
      messages.html('');

      $.each(data, function(k, v){
        let link = v["platform"] == "facebook" ? "https://facebook.com/"+v["comment_id"] : v["link"];
        
        if(v["team_responded"] === true){
          messages.append('<div class="message">'+
                            '<div class="data">'+
                              '<div class="question">'+
                                '<img src="https://png.icons8.com/color/48/9D7CC1/comments.png">'+
                                '<p>'+ v["message"] +'</p>'+
                              '</div>'+
                              '<div class="answer">'+
                                '<p>'+ v["echo_message"] +'</p>'+
                              '</div>'+
                            '</div>'+
                            '<div class="extras">'+
                              '<time class="timeago" datetime="'+ v["created_at"] +'"></time>'+
                              '<a href="'+ link +'" target="_blank"><i class="fas fa-external-link-alt"></i></a>'+
                            '</div>'+
                          '</div>'
                          );
        } else {
          messages.append('<div class="message">'+
                            '<div class="data">'+
                              '<div class="question">'+
                                '<img src="https://png.icons8.com/color/48/9D7CC1/comments.png">'+
                                '<p>'+ v["message"] +'</p>'+
                              '</div>'+
                            '</div>'+
                            '<div class="extras">'+
                              '<time class="timeago" datetime="'+ v["created_at"] +'"></time>'+
                              '<a href="'+ link +'" target="_blank"><i class="fas fa-external-link-alt"></i></a>'+
                            '</div>'+
                          '</div>'
                          );
        }

      });

      $("time.timeago").timeago();
    }
  });
}

function drawGraph(data){
  $.each(data, function(key, vals) {
    if(vals){
      values = [];
      dates = [];

      $.each(vals, function(index, val){
        values.push(val["value"]);
        date = formatDate(val["day"], 'short');
        dates.push(date);
      });

      var settings = {
        width: '225',
        height: '25',
        type: 'line',
        color: '#9d7cc1',
        lineColor: '#9d7cc1',
        fillColor: '#E7E3EE',
        spotColor: 'transparent',
        minSpotColor: 'transparent',
        maxSpotColor: 'transparent',
        highlightSpotColor: '#9d7cc1',
        highlightLineColor: 'transparent',
        tooltipFormat: '<span style="color: {{color}}">&#9679;</span> {{offset:date}} - <b>{{y:value}}</b>',
        tooltipValueLookups: {
          'date': dates
        }
      };

      if(key == "details") {
        jQuery.extend(settings, {width: '360', height: '125'});
      } else {
        jQuery.extend(settings, {width: '225', height: '25'});
      }

      $('.sparkline#'+key).hide().sparkline(values, settings);
      $('.sparkline').fadeIn();
    }
  });
}

// GET DATE SET
function setDatePeriod(period) {
  let set_date;
  const today = shortDate(new Date());
  const year = shortDate(new Date(new Date().setFullYear(new Date().getFullYear() - 1))),
        month = shortDate(new Date(new Date().setMonth(new Date().getMonth() - 1))),
        twoWeeks = shortDate(new Date(new Date().setDate(new Date().getDate() - 14))),
        week = shortDate(new Date(new Date().setDate(new Date().getDate() - 7)));

  if(period == "year") {
    set_date = year + " - " + today;
  } else if(period == "month") {
    set_date = month + " - " + today;
  } else if(period == "two_weeks") {
    set_date = twoWeeks + " - " + today;
  } else if(period == "week") {
    set_date = week + " - " + today;
  } else if (period == "today") {
    set_date = today;
  }

  return set_date;
}

// SHORT FORMAT DATE
function shortDate(date){
  var shortDateFormat = 'd MMM';
  return jQuery.format.date(date, shortDateFormat)
}
