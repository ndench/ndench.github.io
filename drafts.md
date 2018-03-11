---
layout: default
---

<div class="home">
  <h1 class="page-heading">Drafts</h1>

  {%- if site.drafts.size > 0 -%}
    <ul class="post-list">
      {%- for post in site.drafts -%}
      <li>
        <h3>
          <a class="post-link" href="{{ post.url | relative_url }}">
            {{ post.title | escape }}
          </a>
        </h3>
      </li>
      {%- endfor -%}
    </ul>
  {%- endif -%}

</div>
