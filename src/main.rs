#![allow(unused_variables)]

use std::{
    error::Error,
    io::{BufRead, BufReader, Write},
    net::{TcpListener, TcpStream},
    os::fd::AsRawFd,
    sync::atomic::{AtomicBool, Ordering},
    sync::Arc,
    thread,
};

use argocd_sandbox::ThreadPool;
use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    #[arg(short = 'H', long, default_value = "localhost")]
    host: String,

    #[arg(short, long, default_value = "8080")]
    port: i32,
}

fn main() -> std::io::Result<()> {
    let args = Args::parse();
    let addr = format!("{}:{}", args.host, args.port);
    let pool = ThreadPool::build(4).unwrap();

    let listener = TcpListener::bind(addr.clone())?;
    let local_addr = listener.local_addr()?;

    let fd = listener.as_raw_fd();
    let shutdown = Arc::new(AtomicBool::new(false));
    let server_shutdown = shutdown.clone();
    let handle = thread::spawn(move || {
        for connection in listener.incoming() {
            if server_shutdown.load(Ordering::Relaxed) {
                return;
            }

            match connection {
                Ok(stream) => {
                    pool.execute(|| handle_connection(stream).unwrap());
                }
                Err(e) => {
                    println!("Error: {}", e);
                    break;
                }
            }
        }
    });

    let _ = TcpStream::connect(local_addr);

    println!("Listening on {}", addr);

    handle.join().unwrap();

    println!("Shutting down.");

    Ok(())
}

fn handle_connection(mut stream: TcpStream) -> Result<(), Box<dyn Error>> {
    let version = "1.0.0";
    let buf_reader = BufReader::new(&mut stream);
    let http_request: Vec<_> = buf_reader
        .lines()
        .map(|result| result.unwrap())
        .take_while(|line| !line.is_empty())
        .collect();

    let status_line = "HTTP/1.1 200 OK";
    let contents = format!("Hello, world: v{version}");
    let length = contents.len();

    let response = format!("{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}");

    stream.write_all(response.as_bytes()).unwrap();

    Ok(())
}
