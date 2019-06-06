//= require ../extras/facebook

$(document).ready(function(){
  $('.fb-login-button').click(function(e) {
    $('.fb-login-button, .loader').addClass('load');
    
    FB.login(function(response) {
      const token = response.authResponse["accessToken"];
      const user_id = response.authResponse["userID"];

      if (response.authResponse) {
        FB.api(
          '/'+ user_id,
          'GET',
          {"fields": "id,first_name,last_name", "access_token": token},
          function(response){
            response["provider"] = "facebook";
            response["access_token"] = token;

            userLogin(response);
          }
        );
      };
    }, {
      scope: "public_profile,manage_pages,read_insights,instagram_basic,instagram_manage_comments",
      enable_profile_selector: true
    });
  });
});

function userLogin(auth){
  $.ajax({
    url: '/sign_in',
    type: 'POST',
    data: {'login': true, 'auth': auth},
    dataType: "json",
    statusCode: {
      200: function(res){
        getPages(auth["id"], res["login"]);
      }
    }
  });
}

// GET PAGES
function getPages(user_id, status) {
  FB.api(
    '/'+ user_id +'/accounts',
    'GET',
    {"fields": "name,id,picture,category,access_token,instagram_business_account", "limit": 500},
    function(response) {
      $.ajax({
        url: '/sign_in',
        type: 'POST',
        data: {'pages': true, 'user_id': user_id, 'data': response['data']},
        dataType: "json",
        statusCode: {
          200: function(res){
            if(status == "new"){
              window.location.replace("create_company");
            } else {
              window.location.replace("admin");
            }
          }
        }
      });
    }
  );
}
