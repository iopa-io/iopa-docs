<li class="plugin on">
  <div class="plugin-screenshot">
    <img src="{{ url_for('specs/screenshots/' + plugin.name + '.jpg') }}" class="plugin-screenshot-img">
  </div>
  <a href="{{ url_for('specs/' + plugin.name ) }}" class="plugin-name">{{ plugin.name }}</a>
  <p class="plugin-desc">{{ plugin.description }}</p>
  <div class="plugin-tag-list">
    {% for tag in plugin.tags %}
      <a href="#{{ tag }}" class="plugin-tag">{{ tag }}</a>
    {% endfor %}
  </div>
</li>