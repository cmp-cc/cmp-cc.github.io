{% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}

  {% if theme.duoshuo %}
    {% set duoshuo_shortname = theme.duoshuo.shortname %}
  {% else %}
    {% set duoshuo_shortname = theme.duoshuo_shortname %}
  {% endif %}

  <script type="text/javascript">
    var duoshuoQuery = {short_name:"{{duoshuo_shortname}}"};
    (function() {
      var ds = document.createElement('script');
      ds.type = 'text/javascript';ds.async = true;
      ds.id = 'duoshuo-script';
      ds.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + '//static.duoshuo.com/embed.js';
      ds.charset = 'UTF-8';
      (document.getElementsByTagName('head')[0]
      || document.getElementsByTagName('body')[0]).appendChild(ds);
    })();


  </script>

  {% if theme.duoshuo_info.ua_enable %}
    {% if theme.duoshuo_info.admin_enable %}
      <script src="{{ url_for(theme.vendors) }}/ua-parser-js/dist/ua-parser.min.js"></script>
      <script src="{{ url_for(theme.js) }}/src/hook-duoshuo.js"></script>
    {% endif %}
  {% endif %}

 <script type="text/javascript">
  window.onload = function(){setTimeout(function(){/*无登陆账户*/if(!document.getElementsByClassName("ds-account-control")[0]){var cmp_cc_blog_user=localStorage.getItem("cmp-cc_blog_user");var author_name_value = cmp_cc_blog_user?'value="'+cmp_cc_blog_user+'"':'';var i = '<div class="ds-control-group" style="float:right;padding:6px;"><input type="text" '+author_name_value+'id="author_name_proxy" id="ds-dialog-name"  class="custom_input" style="color:#777;width=80%;font-size:13px;border:1px solid #ccc;height:25px;box-shadow: inset 0 1px 1px;padding: 2px 0px 0px 8px;" placeholder="昵称 or 登陆" required></div>';/*展开一个回复，再关闭。 多说没有参数配置啊~ 让人觉得不优雅*/var $last_ds_post_reply = $(".ds-post-reply:last");$last_ds_post_reply.click().click();$(".ds-post-options.ds-gradient-bg").append(i);$(".ds-post-button").click(function(){$(this).submit();$("#ds-wrapper").hide();var author_name = $("#author_name_proxy").val();$("#ds-wrapper #ds-dialog-name").val(author_name);$("#ds-wrapper form").submit();/*www.cmp-cc.github.com*/localStorage.setItem("cmp-cc_blog_user",author_name);$(".custom_input").val(author_name);});}},300);} 
 </script>

{% endif %}
