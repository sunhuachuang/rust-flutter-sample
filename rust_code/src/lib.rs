use async_std::io::{self, Result};
use async_std::net::{TcpListener, TcpStream};
use async_std::prelude::*;
use async_std::task;

use std::ffi::CString;
use std::os::raw::c_char;

async fn process(stream: TcpStream) -> Result<()> {
    println!("Accepted from: {}", stream.peer_addr()?);

    let (reader, writer) = &mut (&stream, &stream);
    io::copy(reader, writer).await?;

    Ok(())
}

async fn listen(addr: &str) -> Result<()> {
    let listener = TcpListener::bind(addr).await?;
    println!("Listening on {}", listener.local_addr()?);

    let mut incoming = listener.incoming();
    while let Some(stream) = incoming.next().await {
        let stream = stream?;
        task::spawn(async {
            process(stream).await.unwrap();
        });
    }
    Ok(())
}

#[no_mangle]
pub extern "C" fn test_hello() {
    println!("Hello from rust");
}

#[no_mangle]
pub extern "C" fn test_add(x: i32, y: i32) -> i32 {
    x + y + 1
}

#[no_mangle]
pub extern "C" fn test_string(name: *mut c_char, say: *mut c_char) -> *const c_char {
    unsafe {
        let cs_name = CString::from_raw(name);
        let str_name = cs_name.to_str().unwrap_or("");
        let cs_say = CString::from_raw(say);
        let str_say = cs_say.to_str().unwrap_or("");
        let words = format!("{} say: {} from rust!", str_name, str_say);
        let s = CString::new(words).unwrap();
        let p = s.as_ptr();
        std::mem::forget(s);
        p
    }
}

#[no_mangle]
pub extern "C" fn test_listen() {
    let _ = task::block_on(listen("127.0.0.1:8080"));
}
