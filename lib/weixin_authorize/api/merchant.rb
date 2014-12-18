# encoding: utf-8
module WeixinAuthorize
  module Api
    module Merchant

      # 根据订单ID获取订单详情
      # https://api.weixin.qq.com/merchatn/order/getbyid?access_token=ACCESS_TOKEN
      def get_order(orderid)
        post_to_merchant_endpoint("/order/getbyid", {order_id: orderid})
      end

      # 根据订单状态/创建时间获取订单详情
      # https://api.weixin.qq.com/merchatn/order/getbyfilter?access_token=ACCESS_TOKEN
      # 3 possible filters: 
      #   * status
      #     2: yet to ship
      #     3: shipped
      #     5: closed
      #     8: complaint filed
      #   * begintime
      #   * endtime
      # returns "order_list"
      def get_order_by(status: nil, begintime: nil, endtime: nil, **options)
        payload = %w(status begingtime endtime).inject({}){|h,i| v = eval(i); h[i.to_sym] = v if v; h}.merge(options)
        post_to_merchant_endpoint("/order/getbyfilter", payload)
      end

      # 设置订单发货信息
      # https://api.weixin.qq.com/merchatn/order/setdelivery?access_token=ACCESS_TOKEN
      # delivery_company should be the official Chinese name of the company, otherwise we assume it's already the correct code
      def set_order_delivery(order_id, delivery_company, delivery_track_no)
        payload = { 
          order_id: order_id, 
          delivery_company: ( delivery_company_codes[delivery_company] || delivery_company ),
          delivery_track_no: delivery_track_no
        }
        post_to_merchant_endpoint("/order/setdelivery", payload)
      end

      # 关闭订单 
      # https://api.weixin.qq.com/merchatn/order/close?access_token=ACCESS_TOKEN
      def close_order(orderid)
        post_to_merchant_endpoint("/order/close", {order_id: orderid})
      end

      private

      def merchant_base_url
        "/merchant"
      end

      def post_to_merchant_endpoint(path, payload)
        http_post("#{merchant_base_url}#{path}", payload.to_json, {accept: :json}, 'api')
      end

      def delivery_company_codes
        {
          '邮政EMS'  => 'Fsearch_code',
          '申通快递' => '002shentong',
          '中通速递' => '066zhongtong',
          '圆通速递' => '056yuantong',
          '天天快递' => '042tiantian',
          '顺丰速运' => '003shunfeng',
          '韵达快运' => '059Yunda',
          '宅急送'   => '064zhaijisong',
          '汇通快运' => '020huitong',
          '易迅快递' => 'zj001yixun'
        }
      end
    end
  end
end
