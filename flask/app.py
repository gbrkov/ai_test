from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)
redis_master = Redis(host='redis-master', port=6379)
GIT_VERSION=

@app.route('/healthz')
def health_z():
    return "ok"

@app.route('/alert')
def alert_incr():
    redis_master.incr('hit')
    return ""

@app.route('/counter')
def counter_get():
    counter="0"
    if redis.exists("hit"):
        counter = str(redis.get('hit'),'utf-8')
    return counter

@app.route('/version')
def ver():
   return GIT_VERSION



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
