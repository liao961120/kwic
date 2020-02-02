<template>
    <div class="container">
        <div class="header">
            <div class="query">
                <div class="keyword">
                    <input
                        type="text"
                        spellcheck="false"
                        placeholder="[word.regex='^[他我]$' pos='N.*'][word='打' pos='V.*']"
                        v-model.lazy="query.query"
                    />
                    <button v-on:click="searchDB" id="search">Query</button>
                </div>
                <ul class="setting">
                    <li>
                        Left context:
                        <input type="number" v-model="query.left" />
                    </li>
                    <li>
                        Right context:
                        <input type="number" v-model="query.right" />
                    </li>
                    <li>
                        show tag (keyword):
                        <input type="checkbox" v-model="displayOpt.kw.tag" />
                    </li>
                    <li>
                        show tag (context):
                        <input type="checkbox" v-model="displayOpt.ctx.tag" />
                    </li>
                    <li>
                        <input type="radio" name="gender" id="female" value="0" v-model="query.gender"/>
                        <label for="female">Female</label>
                        <input type="radio" name="gender" id='male' value="1" v-model="query.gender"/>
                        <label for="male">Male</label>
                        <input type="radio" name="gender" id='all' value="2" v-model="query.gender"/>
                        <label for="all">All</label>
                    </li>
                    <li class='this-is-placeholder'></li>
                </ul>
            </div>
            <div class="info">
                <button @click="exportTSV" :disabled="isExporting">Export</button>
                <span class="num-of-results">{{ this.results.length }}</span>
            </div>
        </div>

        <div class="results">
            <loading
                loader="spinner"
                :active.sync="query.isLoading"
                :is-full-page="true"
                :can-cancel="true"
            >
                <template v-slot:after>
                    <p class="loading-text">Searching . . .</p>
                </template>
                <!-- <slot name="after"></slot> -->
            </loading>
            <div class="kwic" v-bind:key="idx" v-for="(item, idx) in showResults">
                <span
                    class="left"
                    v-bind:style="{width: kwicStyCtxWidth + '%' }"
                >{{ item['left'] | contextShow(tag=displayOpt.ctx.tag, sep=(displayOpt.ctx.tag ? ' ' : '')) }}</span>
                <span
                    class="key"
                    v-bind:style="{width: kwicStyKeyWidth + '%' }"
                >{{ item['keyword'] | contextShow(tag=displayOpt.kw.tag, sep=(displayOpt.kw.tag ? ' ' : '')) }}</span>
                <span
                    class="right"
                    v-bind:style="{width: kwicStyCtxWidth + '%' }"
                >{{ item['right'] | contextShow(tag=displayOpt.ctx.tag, sep=(displayOpt.ctx.tag ? ' ' : '')) }}</span>
            </div>
            <button v-on:click="showMore" v-if="results.length > 30">Show More</button>
        </div>

            <a id="to-top" onclick="document.documentElement.scrollTop = 0;">▲</a>
            <a id="to-bottom" onclick="window.scrollTo(0, document.body.scrollHeight);">▼</a>
    </div>
</template>

<script>
import VueLoading from "vue-loading-overlay";
import "vue-loading-overlay/dist/vue-loading.css";
import axios from "axios";

export default {
    name: "kwic",
    components: {
        loading: VueLoading
    },
    data() {
        return {
            query: {
                query: "",
                gender: 2,
                left: 10,
                right: 10,
                isLoading: false
            },
            displayOpt: {
                kw: {
                    tag: true,
                    sep: " "
                },
                ctx: {
                    tag: false,
                    sep: ""
                }
            },
            results: [],
            showNext: {
                curr: 30,
                next: 30
            },
            isExporting: false
        };
    },
    methods: {
        searchDB: function() {
            const url = `http://localhost:1420/query?query=${this.query.query}&left=${this.query.left}&right=${this.query.right}&gender=${this.query.gender}`;
            //clean up
            this.showNext.curr = 30;
            this.query.isLoading = true;
            this.$http.get(url).then(function(data) {
                this.results = data.body;
                this.query.isLoading = false;
            });
        },
        showMore: function() {
            this.showNext.curr += this.showNext.next;
        },
        exportTSV: function() {
            this.isExporting = true;

            const url = `http://localhost:1420/export?kwtag=${this.displayOpt.kw.tag}&ctxtag=${this.displayOpt.ctx.tag}`;

            axios
                .get(url, { responseType: "blob" })
                .then(response => {
                    const blob = new Blob([response.data], {
                        type: "text/tsv"
                    });
                    const link = document.createElement("a");
                    link.href = URL.createObjectURL(blob);
                    link.download = "kwic.tsv";
                    link.click();
                    URL.revokeObjectURL(link.href);
                    // Release button
                    this.isExporting = false;
                })
                .catch(console.error);
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
            return (95 - this.results[0].keyword.length * 6) / 2;
        }
    },
    filters: {
        contextShow: function(lst, tag = false, sep = " ") {
            const lst2 = [];
            lst.forEach(elem => {
                if (tag) lst2.push(elem[0] + "/" + elem[1]);
                else lst2.push(elem[0]);
            });

            return lst2.join(sep);
        }
    }
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container {
    width: 90%;
    margin: 30px auto;
}
.header {
    position: fixed;
    margin: 0;
    padding: 20px 0;
    height: 100px;
    width: 90%;
    min-width: 900px;
    top: 0;
    background: white;
}
.query {
    position: relative;
    display: block;
    width: 100%;
    margin-bottom: 0px;
}
.keyword {
    display: inline-block;
    height: 70px;
    width: 64%;
    margin: 0;
    padding: 0;
    text-align: left;
}
.setting {
    display: inline-block;
    height: 80px;
    width: 36%;
    margin: 0;
    padding: 0;
    list-style-type: none;
}
.keyword input,
.keyword button {
    width: 90%;
    margin: 3px;
    padding: 0.45em;
    font-size: 11px;
    font-family: Monaco, "Courier New", Courier, monospace;
}
.keyword input {
    margin: 0;
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
.kwic span {
    display: inline-block;
    width: 40%;
    height: 1.5em;
    /* border: 1px solid black; */
    font-size: 0.78em;
    margin: 3px auto;
    padding: 0.1em;
}
.results .kwic:nth-child(2n + 1) {
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
    margin-top: 175px;
    counter-reset: num;
}
.kwic::before {
    counter-increment: num;
    content: counter(num) " ";
    color: gray;
    font-size: 0.7em;
}
.loading-text {
    color: rgb(42, 42, 42);
}
.info {
    text-align: left;
}
.info span,
.info button {
    display: inline-block;
    margin: 5px 1.2em 5px 0;
    padding: 6px;
    line-height: 0.75em;
}
.info span.num-of-results {
    width: 15em;
    font-size: 0.7em;
    /* text-align: left; */
}
.num-of-results:before {
    content: "總筆數：";
}

button {
    background: rgb(87, 87, 87);
    color: rgb(236, 236, 236);
    padding: 4px;
    margin: 5px;
    border: none;
}
button:hover{
    background: rgb(66, 66, 66);
    color: white;
}
button:active {
    transform: translateY(1px);
}
button:disabled {
    background: rgb(136, 136, 136);
    color: rgb(236, 236, 236);
}

a#to-top, a#to-bottom {
    position: fixed;
    right: 1%;
    background: rgb(121, 121, 121);
    color: rgb(245, 245, 245);
    font-size: 19px;
}
a#to-top:hover, a#to-bottom:hover {
    background: rgb(88, 88, 88);
    color: white;
    font-size: 20px;
    cursor: pointer;
    user-select: none;
}
a#to-top {
    bottom: 40px;
} 
a#to-bottom {
    bottom: 15px;
} 
</style>
