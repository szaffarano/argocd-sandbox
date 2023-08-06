#![allow(unused_variables)]

use std::net::SocketAddr;
use tokio::signal::unix::{signal, SignalKind};

use clap::Parser;
use warp::{http::HeaderValue, hyper::HeaderMap, Filter};

use argocd_sandbox::greet;

#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    #[arg(short = 'H', long, default_value = "127.0.0.1")]
    host: String,

    #[arg(short, long, default_value = "8080")]
    port: i32,
}

#[tokio::main]
async fn main() {
    let build_ts = env!("VERGEN_BUILD_TIMESTAMP");
    let git_hash = env!("VERGEN_GIT_DESCRIBE");
    let version = env!("CARGO_PKG_VERSION");

    let mut headers = HeaderMap::new();
    headers.insert("X-Build-Timestamp", HeaderValue::from_static(build_ts));
    headers.insert("X-Git-Hash", HeaderValue::from_static(git_hash));
    headers.insert("X-App-Version", HeaderValue::from_static(version));

    let args = Args::parse();
    let addr = format!("{}:{}", args.host, args.port)
        .parse::<SocketAddr>()
        .unwrap();

    let routes = warp::path!("hello" / String)
        .map(|name| greet(name))
        .with(warp::reply::with::headers(headers));

    let mut stream = signal(SignalKind::terminate()).unwrap();

    let (_, server) = warp::serve(routes).bind_with_graceful_shutdown(addr, async move {
        println!("Listening on {}...", addr.to_string().as_str());
        stream.recv().await;
    });

    match tokio::join!(tokio::task::spawn(server)).0 {
        Ok(()) => println!("shutting down"),
        Err(e) => println!("unexpected error: {}", e),
    };
}
