# app.py
from flask import Flask, render_template
import feedparser

app = Flask(__name__)

FEEDS = [
    "https://br.investing.com/rss/news.rss",
    # você pode adicionar outros RSS aqui
]

@app.route("/")
def index():
    noticias = []
    for feed_url in FEEDS:
        feed = feedparser.parse(feed_url)
        for entry in feed.entries[:5]:  # pega as 5 primeiras
            noticias.append({
                "titulo": entry.title,
                "link": entry.link,
                "data": entry.published
            })
    return render_template("index.html", noticias=noticias)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
