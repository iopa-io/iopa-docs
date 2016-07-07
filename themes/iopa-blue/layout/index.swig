<header id="banner" class="wrapper">
  <div class="inner">
    <h2 id="banner-title">{{ page.subtitle }}</h2>
   <div class="inner"> 
     <p id="banner-description">{{ page.subdescription }}</p>
   </div>
    <div id="banner-start">
     <a href="docs/" id="banner-get-started-link">{{ __('index.get_started') }}</a>
    </div>
    <div id="banner-share">{{ partial('partial/share') }}</div>
  </div>
</header>
<div id="content-wrap">
  <div class="wrapper">
    <div class="inner">
      {{ page.content }}
      <ul id="intro-cmd-wrap">
        <li class="intro-cmd-item">npm install iopa --save</li>
      </ul>
      <div id="intro-get-started-wrap">
        <a href="docs/" id="intro-get-started-link">{{ __('index.get_started_docs') }}</a>
      </div>
    </div>
  </div>
</div>