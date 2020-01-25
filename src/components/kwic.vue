<template>
  <div class="container">
      <div class="query">
          <input type="text" placeholder="Token (例如：^我們$)" v-model.lazy="query.tk1" id='tk1'> 
          <input type="text" placeholder="PoS (例如：N%)" v-model.lazy="query.pos1" id='pos1'>
          <button v-on:click="searchDB">Query</button>
      </div>
      <div class="results">
        <div class="kwic" v-bind:key="idx" v-for="(item, idx) in showResults">
          <span class="left">{{ item['left'] | contextShow(tag=false, sep="") }}</span>
          <span class="keyword">{{ item['keyword'] | contextShow(tag=true) }}</span>
          <span class="right">{{ item['right'] | contextShow(tag=false, sep="") }}</span>
        </div>
        <button v-on:click="showMore">Show More</button>
      </div>

  </div>
</template>

<script>
export default {
  name: 'kwic',
  data() {
      return {
          query: {
              tk1: "",
              pos1: ""
          },
          results: [],
          showNext: {
            curr: 30,
            next: 30,
          },
          /*
          showResults: [
            {keyword: [['我們', 'N']], left: [['不是', 'V'], ['我們', 'N'], ['我們', 'N'], ['我們', 'N']], right: [['殺', 'V']]},
            {keyword: [['我們', 'N']], left: [['不是', 'V']], right: [['殺', 'V']]},
            {keyword: [['我們', 'N']], left: [['不是', 'V']], right: [['殺', 'V'], ['我們', 'N'], ['我們', 'N']]}
            ],
          */
      }
  },
  methods: {
    "searchDB": function() {
      const url = `http://localhost:1420/onegram?token=${this.query.tk1}&pos=${this.query.pos1}`;
      console.log(url);
      this.$http.get(url).then(function (data) {
                this.results = data.body;
            });
    },
    "showMore": function() {
      console.log("showMore!")
      this.showNext.curr += this.showNext.next;
    }
  },
  computed: {
    showResults() {
      return this.results.slice(0, this.showNext.curr);
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
    .query input {
        display: inline-block;
        margin: 5px;
        padding: 0.8em;
        font-size: 12px;
    }

    ::placeholder {
        color: grey;
    }
    .results span {
      display: inline-block;
      width: 40%;
      border: 1px solid black;
      font-size: 0.85em;
      margin: 3px auto;
      padding: 0.1em;
    }
    .keyword {
      max-width: 13%;
    }
    .left {
      text-align: right;
    }
    .right {
      text-align: left;
    }
    .results {
      counter-reset:num;
    }
    .kwic::before {
      counter-increment:num; 
      content: counter(num) ' ';
      color: gray;
      font-size: 0.7em;
    }
</style>
