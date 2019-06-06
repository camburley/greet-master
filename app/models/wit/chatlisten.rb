class Wit::Chatlisten
  def self.get_response(wit_json)
    wit = wit_json.with_indifferent_access[:entities]

    if wit
      productShipping = wit[:productShipping][0][:value] if wit[:productShipping]
      productShippingConfid = wit[:productShipping][0][:confidence] if wit[:productShipping]
      userQuestion = wit[:user_question][0][:value] if wit[:user_question]
      userQuestionConfid = wit[:user_question][0][:confidence] if wit[:user_question]
      queryIntent = wit[:intent][0][:value] if wit[:intent] if wit[:intent]
      queryIntentConfid = wit[:intent][0][:confidence] if wit[:intent]
      productMfg = wit[:productMfg][0][:value] if wit[:productMfg]
      productMfgConfid = wit[:productMfg][0][:confidence] if wit[:productMfg]
      productCare = wit[:productCare][0][:value] if wit[:productCare]
      productCareConfid = wit[:productCare][0][:confidence] if wit[:productCare]
      product = wit[:product][0][:value] if wit[:product]
      productConfid = wit[:product][0][:confidence] if wit[:product]
      productChange = wit[:productChange][0][:value] if wit[:productChange]
      productChangeConfid = wit[:productChange][0][:confidence] if wit[:productChange]
      isItPossible = wit[:isItPossible_][0][:value] if wit[:isItPossible]
      isItPossibleConfid = wit[:isItPossible_][0][:confidence] if wit[:isItPossible_]
      productDiscount = wit[:productDiscount][0][:value] if wit[:productDiscount]
      productDiscountConfid = wit[:productDiscount][0][:confidence] if wit[:productDiscount]
      productOrigin = wit[:productOrigin][0][:value] if wit[:productOrigin]
      productOriginValue = wit[:productOrigin][0][:value] if wit[:productOrigin]
      productOriginConfid = wit[:productOrigin][0][:confidence] if wit[:productOrigin]
      productRefund = wit[:productRefund][0][:value] if wit[:productRefund]
      productRefund = wit[:productRefund][0][:confidence] if wit[:productRefund]
      acceptedVendors = wit[:vendorAccept][0][:value] if wit[:vendorAccept]
      acceptedVendorsConfid = wit[:vendorAccept][0][:confidence] if wit[:vendorAccept]
      paymentMethod = wit[:paymentMethod][0][:value] if wit[:paymentMethod]
      paymentMethodConfid = wit[:paymentMethod][0][:confidence] if wit[:paymentMethod]
      productMonitor = wit[:productMonitor][0][:value] if wit[:productMonitor]
      productMonitorConfid = wit[:productMonitor][0][:confidence] if wit[:productMonitor]
      recentProductOrder = wit[:recentProductOrder][0][:value] if wit[:recentProductOrder]
      recentProductOrderConfid = wit[:recentProductOrder][0][:confidence] if wit[:recentProductOrder]
      productDonations = wit[:productDonations][0][:value] if wit[:productDonations]
      productDonationsConfid = wit[:productDonations][0][:confidence] if wit[:productDonations]
      productPOS = wit[:productPOS][0][:value] if wit[:productPOS]
      productPOSConfid = wit[:productPOS][0][:confidence] if wit[:productPOS]
      customOrder = wit[:customOrder][0][:value] if wit[:customOrder]
      customOrderConfid = wit[:customOrder][0][:confidence] if wit[:customOrder]
      humanCondition = wit[:humanCondition][0][:value] if wit[:humanCondition]
      humanConditionConfid = wit[:humanCondition][0][:confidence] if wit[:humanCondition]
      productAvailability = wit[:productAvailability][0][:value] if wit[:productAvailability]
      productAvailabilityValue = wit[:productAvailability][0][:value] if wit[:productAvailability]
      productAvailabilityConfid = wit[:productAvailability][0][:confidence] if wit[:productAvailability]
      productQuestion = wit[:productQuestion][0][:value] if wit[:productQuestion]
      productQuestionConfid = wit[:productQuestion][0][:confidence] if wit[:productQuestion]
      pilling = wit[:pilling][0][:value] if wit[:pilling]
      pillingConfid = wit[:pilling][0][:confidence] if wit[:pilling]
      doIngredientsInclude = wit[:doIngredientsInclude][0][:value] if wit[:doIngredientsInclude]
      doIngredientsIncludeConfid = wit[:doIngredientsInclude][0][:confidence] if wit[:doIngredientsInclude]
      productIngredients = wit[:productIngredients][0][:value] if wit[:productIngredients]
      productIngredientsValue = wit[:productIngredients][0][:value] if wit[:productIngredients]
      productIngredientsConfid = wit[:productIngredients][0][:confidence] if wit[:productIngredients]
      material = wit[:material][0][:value] if wit[:material]
      materialConfid = wit[:material][0][:confidence] if wit[:material]
      userActivity = wit[:userActivity][0][:value] if wit[:userActivity]
      userActivityConfid = wit[:userActivity][0][:confidence] if wit[:userActivity]
      noCustomerServiceResponse = wit[:noCustomerServiceResponse][0][:value] if wit[:noCustomerServiceResponse]
      noCustomerServiceResponseConfid = wit[:noCustomerServiceResponse][0][:confidence] if wit[:noCustomerServiceResponse]
      productDamage = wit[:productDamage][0][:value] if wit[:productDamage]
      productDamageConfid = wit[:productDamage][0][:confidence] if wit[:productDamage]
      emphasis = wit[:emphasis][0][:value] if wit[:emphasis]
      emphasisConfid = wit[:emphasis][0][:confidence] if wit[:emphasis]




      # prodShrinkAnswers
      if productChange && productChangeConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion >= 0.85
        intent = "product_change_question"

      # internationalShip
      elsif productShipping && productShippingConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_shipping_question"

      # trackMyOrder
      elsif isItPossible && isItPossibleConfid >= 0.80 && productMonitor && productMonitorConfid >= 0.80 && recentProductOrder && recentProductOrderConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_shipping_question"

      # trackMyOrder
      elsif productMonitor && productMonitorConfid >= 0.80 && recentProductOrder && recentProductOrderConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_shipping_question"

      # trackMyOrder
      elsif recentProductOrder && recentProductOrderConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_shipping_question"

      # acceptPaymentQuestion
      elsif acceptedVendors && acceptedVendorsConfid >= 0.80 && paymentMethod && paymentMethodConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "payment_question"

      # donations
      elsif productDonations && productDonationsConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "donations_question"

      # donations
      elsif productDonations && productDonationsConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "donations_question"

      # howToWash
      elsif productCare && productCareConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_care_question"

      # howToWash
      elsif productCare && productCareConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_care_question"

      # whereToBuy
      elsif productPOS && productPOSConfid >= 0.80 && isItPossible && isItPossibleConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_POS_question"

      # whereToBuy
      elsif productPOS && productPOSConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_POS_question"

      # whereToBuy
      elsif productPOS && productPOSConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_POS_question"

      # customPacks
      elsif customOrder && customOrderConfid >= 0.80 && product && productConfid >= 0.80 && isItPossible && isItPossibleConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_assortment_question"

      # customPacks
      elsif customOrder && customOrderConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_assortment_question"

      # diabetesQues
      elsif isItPossible && isItPossibleConfid >= 0.80 && humanCondition && humanConditionConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "health_related_question"

      # diabetesQues
      elsif humanCondition && humanConditionConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "health_related_question"

      # diabetesQues
      elsif humanCondition && humanConditionConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "health_related_question"

      # pillingQues
      elsif productQuestion && productQuestionConfid >= 0.80 && pilling && pillingConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_change_question"

      # ingredientsLatex
      elsif isItPossible && isItPossibleConfid >= 0.80 && productIngredients && productIngredientsValue == "latex" && productIngredientsConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_materials_question"

      # ingredientsLatex
      elsif doIngredientsInclude && doIngredientsIncludeConfid >= 0.80 && productIngredients && productIngredientsValue == "latex" && productIngredientsConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.70
        intent = "product_materials_question"

      # ingredientsLatex
      elsif doIngredientsInclude && doIngredientsIncludeConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_materials_question"

      # runningSocks
      elsif userActivity && userActivityConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "user_activity_question"

      # madeInUSA
      elsif productMfg && productMfgConfid >= 0.80 && product && productConfid >= 0.80 && productOrigin && ["in America", "in the USA", "in China", "in the US", "domestically", "here"].include?(productOriginValue) && productOriginConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.70
        intent = "product_origin_question"

      #noResponse
      elsif noCustomerServiceResponse && noCustomerServiceResponseConfid >= 0.80 && emphasis && emphasisConfid >= 0.80
        intent = "no_response_frustration"

      #productDamage
      elsif productDamage && productDamageConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80 && queryIntent && queryIntentConfid >= 0.80
        intent = "product_damage_question"

      # doUhaveAvailable
      elsif productAvailability && productAvailabilityConfid >= 0.80 && product && productConfid >= 0.80 && userQuestion && userQuestionConfid >= 0.80
        intent = "product_availability_question"
      else
        customerDisappointment = wit[:customerDisappointment][0][:value] if wit[:customerDisappointment]
        customerDisappointmentConf = wit[:customerDisappointment][0][:confidence] if wit[:customerDisappointment]
        productLove = wit[:productLove][0][:value] if wit[:productLove]
        productLoveConf = wit[:productLove][0][:confidence] if wit[:productLove]

        # CHECK FOR FEEDBACK
        if customerDisappointment && customerDisappointmentConf >= 0.70
          user_feedback = "hate"
        elsif productLove && productLoveConf >= 0.70
          user_feedback = "love"
        end

        # CHECK FOR FLAGS
        if userQuestion && userQuestionConfid >= 0.80
          wit_flag = "user_question"
        else
          wit_flag = "no_match"
        end
      end

      return intent ? {"intent": intent} : user_feedback ? {"user_feedback": user_feedback} : {"wit_flag": wit_flag}
    end
  end
end
