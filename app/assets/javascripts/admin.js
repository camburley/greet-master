// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require jquery_ujs
//= require ./extras/facebook
//= require ./extras/jquery.timeago.js
//= require ./extras/dateformat.js
//= require ./extras/cookie.js

$(function(){
  var tag_search = $('.tag-search'),
      tag_results = $('.tag-results'),
      search_btn = $('.tag-search-btn'),
      close_search = tag_search.find('.close-search'),
      input = tag_search.find('#search-val'),
      date = tag_search.find('.tag-date'),
      body = $('body');

  search_btn.click(function(){
    body.css('overflow', 'hidden');
    tag_search.fadeIn(function(){
      input.keypress(function(e){
        e.stopImmediatePropagation();

        if(e.which == 13){
          var tag = input.val(),
              period = date.val(),
              page_id = $('.page-selected').find('input').val(),
              tag_re = tag.toLowerCase(),
              re = new RegExp(tag_re, 'i');

          $.getJSON({
            url: "/api/v1/tags/"+ page_id,
            data: { period: period, tag: tag },
            dataType: "json",
            success: function(data, message, code){
              tag_results.html('');

              if(code.status === 200) {
                $.each(data, function(k, v){
                  var highlight = v["message"].replace(re, '<span id="highlight">'+ tag +'</span>');

                  tag_results.append('<div class="message">'+
                                      '<div class="data">'+
                                        '<div class="question">'+
                                          '<img src="https://png.icons8.com/color/48/9D7CC1/comments.png">'+
                                          '<p>'+ highlight +'</p>'+
                                        '</div>'+
                                      '</div>'+
                                      '<div class="extras">'+
                                        '<time class="timeago" datetime="'+ v["created_at"] +'"></time>'+
                                        '<a href="https://www.facebook.com/'+ v["comment_id"] +'" target="_blank"><i class="fas fa-external-link-alt"></i></a>'+
                                      '</div>'+
                                    '</div>'
                                    );
                });

                $("time.timeago").timeago();
              } else {
                tag_results.append('<h1 id="no-content">No tags found.</h1>')
              }
            }
          });
        }
      });

      close_search.click(function(){
        body.css('overflow', 'initial');
        tag_search.fadeOut();
      });
    });
  });
});

function imgError(image) {
    image.onerror = "";
    image.src = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/450px-No_image_available.svg.png";
    return true;
}

function nFormatter(num) {
     if (num >= 1000000000) {
        return (num / 1000000000).toFixed(1).replace(/\.0$/, '') + 'G';
     }
     if (num >= 1000000) {
        return (num / 1000000).toFixed(1).replace(/\.0$/, '') + 'M';
     }
     if (num >= 1000) {
        return (num / 1000).toFixed(1).replace(/\.0$/, '') + 'K';
     }
     return num;
}

// DATE FORMAT
function formatDate(value, type) {
  var monthShortNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];

  var value = new Date(value);
  if(type == 'long') {
    return value.getDate() + " " + monthShortNames[value.getMonth()] + " " + value.getHours() + ":" + (value.getMinutes()<10?'0':'') + value.getMinutes();
  } else {
    return value.getDate() + 1 + " " + monthShortNames[value.getMonth()] + " " + value.getFullYear();
  }
}

// CREATE CSV
function convertArrayOfObjectsToCSV(args) {
  var result, ctr, keys, columnDelimiter, lineDelimiter, data;

  data = args.data || null;
  if (data == null || data == "undefined") {
      return null;
  }

  columnDelimiter = args.columnDelimiter || ',';
  lineDelimiter = args.lineDelimiter || '\n';

  result = '';
  result += "Insight,Value,Value/Per Post";
  result += lineDelimiter;

  var elements = Object.getOwnPropertyNames(data);

  elements.forEach(function(el){

    result += data[el]["title"];
    result += columnDelimiter;
    result += data[el]["total"] || 0;
    result += columnDelimiter;
    result += data[el]["per_post"] || 0;
    result += lineDelimiter;
  });

  result += lineDelimiter;
  result += args.time_stamp;

  return result;
}

// PREPARE DOWNLOAD FOR CSV
function downloadCSV(period) {
  var data, filename, link, json, time_stamp;
  time_stamp = setDatePeriod(period);
  json = export_json;

  var csv = convertArrayOfObjectsToCSV({
      data: json,
      time_stamp: time_stamp
  });
  if (csv == null) return;

  filename = "greet_"+ time_stamp.replace(/\s+/g, '').replace(/-/g, '_') +".csv";

  if (!csv.match(/^data:text\/csv/i)) {
      csv = 'data:text/csv;charset=utf-8,' + csv;
  }
  data = encodeURI(csv);


  link = document.createElement('a');
  link.setAttribute('href', data);
  link.setAttribute('download', filename);
  link.click();
}

// URL PARSER
function parseUrl( url ) {
  var a = document.createElement('a');
  a.href = url;
  return a.hostname;
}
