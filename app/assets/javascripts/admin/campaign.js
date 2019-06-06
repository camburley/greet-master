var export_json;

$(function(){
    let pageId;
    const pagesWidget = $('.page-widget'),
          pages = pagesWidget.find('li'),
          pageSelected = $('.page-selected');

    var first_page = pages.first();
    pageSelected.html(first_page.html())
                 .click(function(){
                   pagesWidget.toggle();
                 });
    
    // GET PAGE ID (cookie)
    c_pageId = Cookies.get('pid');
    pageId = (c_pageId) ? c_pageId : first_page.find('input').val();

    if (c_pageId !== undefined) {
      const c_page = pages.find('input[value="'+ c_pageId +'"]');
      pageSelected.html(c_page.parent('.page').html());
    }

    getCampaigns(pageId);

    // IF PAGE SELECTED (COOKIES)
    pages.click(function(){
      pageId = $(this).find('input').val();

      pageSelected.html($(this).html());
      pagesWidget.hide();

      Cookies.set('pid', pageId, { expires: 7 });
      getCampaigns(pageId);
    });

    $(document).mouseup(function(e) {
      if (!pagesWidget.is(e.target) && pagesWidget.has(e.target).length === 0) {
        pagesWidget.hide();
      }
    });

    // SCROLL DATA SYNC
    $('.page-stats .echo-data').on('scroll', function(){
      $('.compare-stats .echo-data').scrollLeft($(this).scrollLeft());
    });

    // SEARCH -- CHANGE
    $('#search').keyup(function(){
      var val = $(this).val().toLowerCase();
      var title = $('.campaign .details p');
      title.closest('.campaign').hide();
      title.each(function(){
        var text = $(this).text().toLowerCase();
        if(text.indexOf(val) != -1) {
          $(this).closest('.campaign').css('display', 'flex');
        }
      });

      $(document).click(function(){
        $('#search').val('');
      });
    });

    // EXPORT
    $('#export_csv').click(function(){
      var period = date.find(':selected').val();
      downloadCSV(period);
    });

    // ON LOAD
    sortTable();
});


// =========
// FUNCTIONs
// =========

  function getCampaigns(pageId) {
    const campaignList = $('.campaign-data .campaign-list'),
          campaignCount = $('.campaign-menu #count'),
          echoData = $('.stats, .tags');

    campaignList.empty();
    campaignCount.html('( 0 )');
    echoData.hide();

    $.getJSON({
      url: "/api/v1/campaigns/"+ pageId,
      statusCode: {
        200: function(campaigns){
          campaignList.html('');
          campaignCount.html('( '+ campaigns.length +' )');

          $.each(campaigns, function(index, campaign){
            let title = campaign.title,
                startDateForm = jQuery.format.date(campaign.start_date, "MMM dd"),
                endDateForm = jQuery.format.date(campaign.end_date, "MMM dd");

            campaignList.append('<div class="campaign" data-id="'+ campaign.id +'">'+
                                  '<div class="data">'+
                                    '<div class="details">'+
                                      '<p id="title">'+ title +'</p>'+
                                      '<p id="time">'+ startDateForm +' - '+ endDateForm +'</p>'+
                                    '</div>'+
                                    '<div class="setting">'+
                                      '<div class="echo-setting">'+
                                        '<label class="switch">'+
                                        '<input class="option" type="checkbox">'+
                                        '<span class="slider round"></span>'+
                                        '</label>'+
                                      '</div>'+
                                    '</div>'+
                                  '</div>'+
                                '</div>');
          });

          $('.campaign').show();

          // SELECT FIRST CAMPAIGN
          const firstCampaign = $('.campaign-list .campaign').first();
          firstCampaign.find('.option').attr('checked', true);
          getData(pageId, firstCampaign.data('id'));

          // GET DATE & PULL DATA
          $('.echo-setting .option').on('change', function(){
            $('.echo-setting .option').attr('checked', false);
            this.checked = true;

            if (this.checked){
              const campaign = $(this).closest('.campaign');
              $('.stats, .tags').hide();

              getData(pageId, campaign.data('id'));
            }
          });
        }
      }
    });
  }

  // GET POST DATA
  function getData(pageId, campaignId) {
    $.getJSON({
      url: "/api/v1/campaign_data/"+ pageId,
      data: { campaign_id: campaignId },
      dataType: "json",
      success: function(data){
        const compareStats = $('.page-stats '),
              compareData = compareStats.find('.data-menu li');
              tableImage = $('.compare .brand table td#image');
              echoData = compareStats.find('.echo-data');

        if (data.extras) {
          compareData.empty().prepend('<img src="'+ data.extras.picture +'" />');
          compareData.append('<span>'+ data.extras.name +'</span>');
          tableImage.empty().prepend('<img src="'+ data.extras.picture +'" />');
        }

        echoData.html('');

        export_json = data;
        $.each(data, function(k,v){
          if(v.hasOwnProperty('total')){
            echoData.append('<div class="echo" data-key="'+ k +'">'+
                              '<p class="title">'+ v["title"] +'</p>'+
                              '<div class="data">'+
                                '<span class="count" id="main">'+ (v["total"] || 0) +'</span>'+
                              '</div>'+
                            '</div>');
          }
        });

        getCompareData(pageId, campaignId);
      }
    });
  }

  function getCompareData(pageId, campaignId) {
    $.getJSON({
      url: "/api/v1/campaign_compare_data/"+ pageId,
      data: { campaign_id: campaignId },
      dataType: "json",
      success: function(data){
        const compareStats = $('.compare-stats '),
              pageStats = $('.page-stats'),
              compareData = compareStats.find('.data-menu li');
              tableImage = $('.compare .campaigns table td#image');
              echoData = compareStats.find('.echo-data');
              extras = data.extras.slice(0,4);

        if (extras) {
          tableImage.find('img').remove();
          compareData.find('img').remove();
          compareData.find('span').html('Compared ('+ data.extras.length +')');
          $.each(extras, function(k,v){
            compareData.prepend('<img src="'+ v.picture +'" />');
            tableImage.prepend('<img src="'+ v.picture +'" />');
          });
        }

        echoData.html('');

        export_json = data;
        $.each(data, function(k,v){
          let compareVal = pageStats.find(".echo[data-key='" + k + "'] .count").text(),
              compareRes = getPercentageChange(compareVal, v["total"] || 0),
              percResult = isFinite(compareRes) && compareRes ? compareRes.toFixed() : "&infin;",
              status = percResult > 0 ? "fa-caret-up" : percResult < 0 ? "fa-caret-down" : "fa-circle"
          
          if(v.hasOwnProperty('total')){
            echoData.append('<div class="echo" data-key="'+ k +'">'+
                              '<p class="title">'+ v["title"] +'</p>'+
                              '<div class="data">'+
                                '<span class="count" id="main">'+ (v["total"] || 0) +'</span>'+
                              '</div>'+
                              '<div class="difference">'+
                                '<span><i class="fas '+ status +'"></i>'+ percResult +'%</span>'+
                              '</div>'+
                            '</div>');
          }
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

        getTagData(pageId, campaignId);
      }
    });
  }

  // GET POST DATA
  function getTagData(pageId, campaignId) {
    $.getJSON({
      url: "/api/v1/tag_insights/"+ pageId,
      data: { campaign_id: campaignId },
      dataType: "json",
      success: function(data){
        pageTable = $('.brand .table tbody');
        compareTable = $('.campaigns .table tbody');

        pageTable.empty();
        compareTable.empty();

        $.each(data, function(key,val){
          $.each(val, function(k,v){
            let compareRes = v["pos_conversation"],
                percResult = isFinite(compareRes) && compareRes ? compareRes.toFixed(1) : 0;

            if (key === "page") {
              pageTable.append('<tr>'+
                                '<td>'+ v["tag"] +'</td>'+
                                '<td id="con">'+ v["conversations"] +'</td>'+
                                '<td id="poscon">'+ percResult +'%</td>'+
                              '</tr>');
            } else if (key === "compare" ) {
              compareTable.append('<tr>'+
                                    '<td>'+ v["tag"] +'</td>'+
                                    '<td id="con">'+ v["conversations"] +'</td>'+
                                    '<td id="poscon">'+ percResult +'%</td>'+
                                  '</tr>');
            }
          });
        });

        $('.stats, .tags').fadeIn();

        showTab(pageId, campaignId);
        postData(pageId, campaignId);
      }
    });
  }

  // DATA FOR POST
  function postData(pageId, campaignId) {
    $.getJSON({
      url: "/api/v1/campaign_posts/"+ pageId,
      data: { campaign_id: campaignId },
      dataType: "json",
      success: function(data){
        const pageList = $('.page-compare');
        pageList.empty();

        $.each(data, function(k, pageData){
          const comparePost = pageData.compare_post,
                page = pageData.page,
                posts = pageData.posts;

          let postList = '<div class="post-list">';
          if(posts.length > 0) {
            $.each(posts, function(k, postData){
              postList += '<div class="post">'+
                            '<img src="'+ postData.image +'">'+
                            '<p id="title">'+ postData.message +'</p>'+
                            '<div class="setting">'+
                              '<div class="echo-setting">'+
                                '<label class="switch">'+
                                '<input class="option" type="checkbox">'+
                                '<span class="slider round"></span>'+
                                '</label>'+
                              '</div>'+
                            '</div>'+
                          '</div>';
            });
          } else {
            postList += '<p id="no-post">No Posts.</p>';
          }
          postList += '</div>';
          
          pageList.append('<div class="page">'+
                                    '<div class="page-info">'+
                                      '<img src="'+ page.picture +'">'+
                                      '<p>'+ page.name +'</p>'+
                                    '</div>'+
                                    postList +
                                  '</div>');
        });
      }
    });
  }

  // SHOW TAB
  function showTab(pageId, campaignId) {
    const tabBtn = $('.btntab'),
          tabTarget = $('.tab');

    tabBtn.click(function(e){
      e.stopImmediatePropagation();
      let btnId = $(this).attr('id');

      tabBtn.removeClass('active');
      $(this).addClass('active');

      tabTarget.fadeOut().removeClass('active');
      $('.tab.'+ btnId).fadeIn().addClass('active');
    });
  }

  // CREATE WIZARD
  function showWizard() {
    const modal = $('.modal'),
          wizard = $('.wizard'),
          compare = wizard.find('#compare select'),
          pagesWidget = $('.page-widget'),
          pages = pagesWidget.find('li'),
          pageSelected = $('.page-selected');

    compare.empty();
    $.each(pages, function(){
      let page = $(this),
          name = page.find('span'),
          image = page.find('img'),
          id = page.find('input#page-id').val(),
          pageId = pageSelected.find('input#page-id');
      
      wizard.find('#page-id').val(pageId.val());
      compare.append('<option style="background-image:url('+ image.attr('src') +');" value="'+ id +'">'+ name.text() +'</option>')
    });

    modal.fadeIn(function(){
      modal.click(function(e){
        if (!wizard.is(e.target) && wizard.has(e.target).length === 0) {
          modal.fadeOut();
        }
      });
    });
  }

  // PERCENTAGE CHANGE
  function getPercentageChange(x, y){
    var x1 = y - x;
    return (x1 / x) * 100;
  }

  // SORT TABLE
  function sortTable() {
    $('th').click(function(){
      $('th').removeClass('sort');
      $(this).addClass('sort');

      var table = $(this).parents('table').eq(0)
      var rows = table.find('tr:gt(0)').toArray().sort(comparer($(this).index()))
      this.asc = !this.asc
      if (!this.asc){rows = rows.reverse()}
      for (var i = 0; i < rows.length; i++){table.append(rows[i])}
    })
  }
  function comparer(index) {
      return function(a, b) {
          var valA = getCellValue(a, index), valB = getCellValue(b, index)
          return $.isNumeric(valA) && $.isNumeric(valB) ? valA - valB : valA.toString().localeCompare(valB)
      }
  }
  function getCellValue(row, index){ return $(row).children('td').eq(index).text() }
