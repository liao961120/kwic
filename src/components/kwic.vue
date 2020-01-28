<template>
  <div class="container">
      <div class="header">
        <div class="query">
          <div class="keyword">
            <input type="text" spellcheck="false" placeholder="[word.regex='^[他我]$' pos='N.*'][word='打' pos='V.*']" v-model.lazy="query.query"> 
            <button v-on:click="searchDB" id="search">Query</button>
          </div>
          <ul class="setting">
              <li>Left context: <input type="number" v-model="query.left"></li>
              <li>Right context: <input type="number" v-model="query.right"></li>
              <li>show tag (keyword): <input type="checkbox" v-model="displayOpt.kw.tag"></li>
              <li>show tag (context): <input type="checkbox" v-model="displayOpt.ctx.tag"></li>
          </ul>

        </div>
      </div>
      
      <div class="results">
        <div class="num-of-results">{{ this.results.length }}</div>
        <loading loader="spinner" :active.sync="query.isLoading" :is-full-page="true" :can-cancel="true">
          <template v-slot:after>
            <p class="loading-text">Searching . . .</p>
          </template>
          <!-- <slot name="after"></slot> -->
        </loading>
        <div class="kwic" v-bind:key="idx" v-for="(item, idx) in showResults">
          <span class="left" v-bind:style="{width: kwicStyCtxWidth + '%' }">{{ item['left'] | contextShow(tag=displayOpt.ctx.tag, sep=(displayOpt.ctx.tag ? ' ' : '')) }}</span>
          <span class="key" v-bind:style="{width: kwicStyKeyWidth + '%' }">{{ item['keyword'] | contextShow(tag=displayOpt.kw.tag, sep=(displayOpt.kw.tag ? ' ' : '')) }}</span>
          <span class="right" v-bind:style="{width: kwicStyCtxWidth + '%' }">{{ item['right'] | contextShow(tag=displayOpt.ctx.tag, sep=(displayOpt.ctx.tag ? ' ' : '')) }}</span>
        </div>
        <button v-on:click="showMore">Show More</button>
      </div>

  </div>
</template>

<script>
import VueLoading from 'vue-loading-overlay'
import 'vue-loading-overlay/dist/vue-loading.css'

export default {
  name: 'kwic',
  components: {
    loading: VueLoading,
  },
  data() {
      return {
          query: {
              query: "",
              left: 10,
              right: 10,
              isLoading: false,
          },
          displayOpt: {
            kw: {
              tag: true,
              sep: " ",
            },
            ctx: {
              tag: false,
              sep: "",
            }
          },
          results: [
            {keyword: [['我們', 'N']], left: [['不是', 'V'], ['我們', 'N'], ['我們', 'N'], ['我們', 'N']], right: [['殺', 'V']]},
            {keyword: [['我們', 'N']], left: [['不是', 'V']], right: [['殺', 'V']]},
            {keyword: [['我們', 'N']], left: [['不是', 'V']], right: [['殺', 'V'], ['我們', 'N'], ['我們', 'N']]}
          ],
          showNext: {
            curr: 30,
            next: 30,
          },
      }
  },
  methods: {
    "searchDB": function() {
      const url = `http://localhost:1420/query?query=${this.query.query}&left=${this.query.left}&right=${this.query.right}`;
      //clean up
      this.showNext.curr = 30;
      this.query.isLoading = true;
      this.$http.get(url).then(function (data) {
                this.results = data.body;
                this.query.isLoading = false;
            });
    },
    "showMore": function() {
      this.showNext.curr += this.showNext.next;
    }
  },
  computed: {
    showResults() {
      return this.results.slice(0, this.showNext.curr);
    },
    kwicStyKeyWidth() {
      return this.results[0].keyword.length * 6;
    },
    kwicStyCtxWidth() {
      return ((95 - this.results[0].keyword.length * 6) / 2);
    }
  },
  filters: {
    contextShow: function(lst, tag=false, sep=" ") {
      const lst2 = [];
      lst.forEach(elem => {
        if (tag)
          lst2.push(elem[0] + '/' + elem[1]);
        else
          lst2.push(elem[0])
      });
      
      return lst2.join(sep);
    }
  }

}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    .container {
        width: 90%;
        margin: 30px auto;
    }
    .query {
      display: block;
      width: 100%;
    }
    .keyword {
      display: inline-block;
      height: 80px;
      width: 60%;
      margin: 0 auto;
    }
    .setting {
      display: inline-block;
      height: 80px;
      width: 30%;
      margin: 0 auto;
      list-style-type: none;
    }
    .keyword input,
    .keyword button {
        width: 90%;
        margin: 3px;
        padding: 0.45em;
        font-size: 11px;
        font-family: Monaco, 'Courier New', Courier, monospace;
    }
    button#search {
      margin: 5px auto;
      width: 30%;
      padding: 5px;
    }
    .setting li {
      display: inline-block;
      padding: 5px;
      margin: 3px;
      width: 45%;
      font-size: 12px;
    }
    .setting input[type="number"] {
      padding: 0;
      width: 2.5em;
    }
    .results span {
      display: inline-block;
      width: 40%;
      height: 1.5em;
      /* border: 1px solid black; */
      font-size: 0.78em;
      margin: 3px auto;
      padding: 0.1em;
    }
    .results .kwic:nth-child(2n+1) {
      background: rgba(238, 238, 238, 0.931);
    }
    .results span.key {
      text-align: center;
      color: red;
    }
    .left {
      text-align: right;
    }
    .right {
      text-align: left;
    }
    .results {
      counter-reset: num;
    }
    .kwic::before {
      counter-increment:num; 
      content: counter(num) ' ';
      color: gray;
      font-size: 0.7em;
    }
    .loading-text {
      color: rgb(42, 42, 42);
    }
    .num-of-results:before {
      content: "總筆數："
    }
    .num-of-results {
      font-size: 0.7em;
      text-align: left;
      text-indent: 2.8em;
      margin-bottom: 3px;
    }
</style>
