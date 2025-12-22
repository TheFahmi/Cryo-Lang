#![allow(dead_code)]
#![allow(unused_variables)]
#![allow(unused_imports)]

use std::ffi::CStr;
use std::os::raw::c_char;
use std::ptr;
use std::net::{TcpListener, TcpStream};
use std::io::{Read, Write};

// ============================================
// ARGON RUNTIME LIBRARY (RUST EDITION)
// ============================================

// --- TYPES ---
const OBJ_STRING: u64 = 0;
const OBJ_ARRAY: u64 = 1;

#[repr(C)]
struct ObjHeader {
    type_tag: u64,
}

#[repr(C)]
struct ObjString {
    pub header: ObjHeader,
    pub data: String,
}

#[repr(C)]
struct ObjArray {
    pub header: ObjHeader,
    pub items: Vec<i64>,
}

// --- TAGGING HELPERS ---
fn is_int(val: i64) -> bool {
    (val & 1) == 1
}

fn is_ptr(val: i64) -> bool {
    (val & 1) == 0 && val != 0
}

fn to_int(val: i64) -> i64 {
    val >> 1
}

fn from_int(n: i64) -> i64 {
    (n << 1) | 1
}

// --- EXPORTED FUNCTIONS ---

#[no_mangle]
pub extern "C" fn argon_add(a: i64, b: i64) -> i64 {
    if is_int(a) && is_int(b) {
        return from_int(to_int(a) + to_int(b));
    }
    // String concatenation
    if is_ptr(a) && is_ptr(b) {
        unsafe {
            let header_a = a as *mut ObjHeader;
            let header_b = b as *mut ObjHeader;
            if (*header_a).type_tag == OBJ_STRING && (*header_b).type_tag == OBJ_STRING {
                let str_a = a as *mut ObjString;
                let str_b = b as *mut ObjString;
                let concatenated = format!("{}{}", &(*str_a).data, &(*str_b).data);
                let cstr = std::ffi::CString::new(concatenated).unwrap();
                return argon_str_new(cstr.as_ptr());
            }
        }
    }
    // String + Int or Int + String
    if is_ptr(a) && is_int(b) {
        unsafe {
            let header = a as *mut ObjHeader;
            if (*header).type_tag == OBJ_STRING {
                let str_obj = a as *mut ObjString;
                let concatenated = format!("{}{}", &(*str_obj).data, to_int(b));
                let cstr = std::ffi::CString::new(concatenated).unwrap();
                return argon_str_new(cstr.as_ptr());
            }
        }
    }
    if is_int(a) && is_ptr(b) {
        unsafe {
            let header = b as *mut ObjHeader;
            if (*header).type_tag == OBJ_STRING {
                let str_obj = b as *mut ObjString;
                let concatenated = format!("{}{}", to_int(a), &(*str_obj).data);
                let cstr = std::ffi::CString::new(concatenated).unwrap();
                return argon_str_new(cstr.as_ptr());
            }
        }
    }
    from_int(0)
}

#[no_mangle]
pub extern "C" fn argon_sub(a: i64, b: i64) -> i64 {
    from_int(to_int(a) - to_int(b))
}

#[no_mangle]
pub extern "C" fn argon_mul(a: i64, b: i64) -> i64 {
    from_int(to_int(a) * to_int(b))
}

#[no_mangle]
pub extern "C" fn argon_div(a: i64, b: i64) -> i64 {
    let vb = to_int(b);
    if vb == 0 { return from_int(0); }
    from_int(to_int(a) / vb)
}

#[no_mangle]
pub extern "C" fn argon_lt(a: i64, b: i64) -> i64 {
    if to_int(a) < to_int(b) { from_int(1) } else { from_int(0) }
}

#[no_mangle]
pub extern "C" fn argon_gt(a: i64, b: i64) -> i64 {
    if to_int(a) > to_int(b) { from_int(1) } else { from_int(0) }
}

#[no_mangle]
pub extern "C" fn argon_eq(a: i64, b: i64) -> i64 {
    // Same value (including same pointer)
    if a == b { 
        return from_int(1); 
    }
    
    // Both are pointers - check if ObjStrings with same content
    if is_ptr(a) && is_ptr(b) {
        unsafe {
            let header_a = a as *mut ObjHeader;
            let header_b = b as *mut ObjHeader;
            if (*header_a).type_tag == OBJ_STRING && (*header_b).type_tag == OBJ_STRING {
                let str_a = a as *mut ObjString;
                let str_b = b as *mut ObjString;
                if (&(*str_a).data) == (&(*str_b).data) {
                    return from_int(1);
                }
            }
        }
    }
    
    from_int(0)
}

// --- ALLOCATION STUBS (Minimal) ---
fn alloc_obj(size: usize, tag: u64) -> *mut ObjHeader {
    let layout = std::alloc::Layout::from_size_align(size, 8).unwrap();
    let ptr = unsafe { std::alloc::alloc(layout) as *mut ObjHeader };
    unsafe { (*ptr).type_tag = tag };
    ptr
}

#[no_mangle]
pub extern "C" fn argon_str_new(s: *const c_char) -> i64 {
    let c_str = unsafe { CStr::from_ptr(s) };
    let r_str = c_str.to_string_lossy().into_owned();
    let size = std::mem::size_of::<ObjString>();
    let ptr = alloc_obj(size, OBJ_STRING) as *mut ObjString;
    unsafe {
        ptr::write(&mut (*ptr).data, r_str);
    }
    ptr as i64
}

#[no_mangle]
pub extern "C" fn argon_arr_new() -> i64 {
    let size = std::mem::size_of::<ObjArray>();
    let ptr = alloc_obj(size, OBJ_ARRAY) as *mut ObjArray;
    unsafe {
        ptr::write(&mut (*ptr).items, Vec::new());
    }
    ptr as i64
}

#[no_mangle]
pub extern "C" fn argon_push(arr: i64, val: i64) -> i64 {
    if is_ptr(arr) {
        let ptr = arr as *mut ObjArray;
        unsafe {
             if (*ptr).header.type_tag == OBJ_ARRAY {
                 (&mut (*ptr).items).push(val);
             }
        }
    }
    arr
}

#[no_mangle]
pub extern "C" fn argon_get(arr: i64, idx: i64) -> i64 {
    if is_ptr(arr) {
        let ptr = arr as *mut ObjHeader;
        unsafe {
             if (*ptr).type_tag == OBJ_ARRAY {
                 let arr_ptr = arr as *mut ObjArray;
                 let items = &(*arr_ptr).items;
                 let idx = to_int(idx) as usize;
                 if idx < items.len() {
                     return items[idx];
                 }
             } else if (*ptr).type_tag == OBJ_STRING {
                 // String indexing: return single-character string
                 let str_ptr = arr as *mut ObjString;
                 let data = &(*str_ptr).data;
                 let idx = to_int(idx) as usize;
                 if idx < data.len() {
                     let ch = &data[idx..idx+1];
                     let cstr = std::ffi::CString::new(ch).unwrap();
                     return argon_str_new(cstr.as_ptr());
                 }
             }
        }
    }
    0 // NULL for out of bounds or invalid type
}

#[no_mangle]
pub extern "C" fn argon_set(arr: i64, idx: i64, val: i64) -> i64 {
    if is_ptr(arr) {
        let ptr = arr as *mut ObjArray;
        unsafe {
             if (*ptr).header.type_tag == OBJ_ARRAY {
                 let idx = to_int(idx) as usize;
                 if idx < (&(*ptr).items).len() {
                     (&mut (*ptr).items)[idx] = val;
                 }
             }
        }
    }
    val
}

#[no_mangle]
pub extern "C" fn argon_len(val: i64) -> i64 {
    if is_ptr(val) {
        unsafe {
            let header = val as *mut ObjHeader;
            if (*header).type_tag == OBJ_ARRAY {
                let arr = val as *mut ObjArray;
                return from_int((*arr).items.len() as i64);
            } else if (*header).type_tag == OBJ_STRING {
                let s = val as *mut ObjString;
                return from_int((&(*s).data).len() as i64);
            }
        }
    }
    from_int(0)
}

#[no_mangle]
pub extern "C" fn argon_get_args() -> i64 {
    let arr = argon_arr_new();
    for arg in std::env::args() {
        let s_ptr = std::ffi::CString::new(arg).unwrap();
        let s_obj = argon_str_new(s_ptr.as_ptr());
        argon_push(arr, s_obj);
    }
    arr
}




#[no_mangle]
pub extern "C" fn argon_char_code_at(s: i64, idx: i64) -> i64 {
    if is_ptr(s) {
        unsafe {
            let header = s as *mut ObjHeader;
            if (*header).type_tag == OBJ_STRING {
                let obj = s as *mut ObjString;
                let data = &(*obj).data;
                let idx = to_int(idx) as usize;
                if idx < data.len() {
                    return from_int(data.as_bytes()[idx] as i64);
                }
            }
        }
    }
    from_int(0)
}

#[no_mangle]
pub extern "C" fn argon_parse_int(s: i64) -> i64 {
    if is_ptr(s) {
        unsafe {
            let header = s as *mut ObjHeader;
            if (*header).type_tag == OBJ_STRING {
                let obj = s as *mut ObjString;
                let data = &(*obj).data;
                if let Ok(n) = data.parse::<i64>() {
                    return from_int(n);
                }
            }
        }
    }
    from_int(0)
}

#[no_mangle]
pub extern "C" fn argon_print(val: i64) {
    if is_int(val) {
        println!("{}", to_int(val));
    } else if is_ptr(val) {
        unsafe {
            let header = val as *mut ObjHeader;
            if (*header).type_tag == OBJ_STRING {
                let obj = val as *mut ObjString;
                println!("{}", &(*obj).data);
            } else {
                println!("[Array]");
            }
        }
    } else {
        println!("[Null]");
    }
}

#[no_mangle]
pub extern "C" fn argon_read_file(path: i64) -> i64 {
    if is_ptr(path) {
        unsafe {
            let header = path as *mut ObjHeader;
            if (*header).type_tag == OBJ_STRING {
                let obj = path as *mut ObjString;
                let path_str = &(*obj).data;
                if let Ok(content) = std::fs::read_to_string(path_str) {
                    let cstr = std::ffi::CString::new(content).unwrap();
                    return argon_str_new(cstr.as_ptr());
                }
            }
        }
    }
    0 // NULL
}

#[no_mangle]
pub extern "C" fn argon_write_file(path: i64, content: i64) -> i64 {
    if is_ptr(path) && is_ptr(content) {
        unsafe {
            let header_p = path as *mut ObjHeader;
            let header_c = content as *mut ObjHeader;
            if (*header_p).type_tag == OBJ_STRING && (*header_c).type_tag == OBJ_STRING {
                let path_obj = path as *mut ObjString;
                let content_obj = content as *mut ObjString;
                let _ = std::fs::write(&(*path_obj).data, &(*content_obj).data);
                return from_int(1);
            }
        }
    }
    from_int(0)
}

#[no_mangle]
pub extern "C" fn argon_file_exists(path: i64) -> i64 {
    if is_ptr(path) {
        unsafe {
            let header = path as *mut ObjHeader;
            if (*header).type_tag == OBJ_STRING {
                let obj = path as *mut ObjString;
                let path_str = &(*obj).data;
                if std::path::Path::new(path_str).exists() {
                    return from_int(1);
                }
            }
        }
    }
    from_int(0)
}

// --- NETWORKING (Added for v2.1) ---

static mut LISTENERS: Vec<Option<TcpListener>> = Vec::new();
static mut STREAMS: Vec<Option<TcpStream>> = Vec::new();

#[no_mangle]
pub extern "C" fn argon_listen(port: i64) -> i64 {
    let port = to_int(port);
    let addr = format!("0.0.0.0:{}", port);
    if let Ok(l) = TcpListener::bind(&addr) {
        unsafe {
            LISTENERS.push(Some(l));
            return from_int((LISTENERS.len() - 1) as i64);
        }
    }
    from_int(-1)
}

#[no_mangle]
pub extern "C" fn argon_accept(id: i64) -> i64 {
    let idx = to_int(id) as usize;
    unsafe {
        if idx < LISTENERS.len() {
            if let Some(l) = &LISTENERS[idx] {
                if let Ok((s, _)) = l.accept() {
                    STREAMS.push(Some(s));
                    return from_int((STREAMS.len() - 1) as i64);
                }
            }
        }
    }
    from_int(-1)
}

#[no_mangle]
pub extern "C" fn argon_socket_read(id: i64) -> i64 {
    let idx = to_int(id) as usize;
    unsafe {
        if idx < STREAMS.len() {
            if let Some(s) = &mut STREAMS[idx] {
                let mut buf = [0u8; 1024];
                if let Ok(n) = s.read(&mut buf) {
                     if n == 0 { return argon_str_new(std::ffi::CString::new("").unwrap().as_ptr()); }
                     let s_str = String::from_utf8_lossy(&buf[..n]).to_string();
                     let cstr = std::ffi::CString::new(s_str).unwrap();
                     return argon_str_new(cstr.as_ptr());
                }
            }
        }
    }
    from_int(0)
}

#[no_mangle]
pub extern "C" fn argon_socket_write(id: i64, str_val: i64) -> i64 {
    let idx = to_int(id) as usize;
    if !is_ptr(str_val) { return from_int(0); }
    unsafe {
        if idx < STREAMS.len() {
             if let Some(s) = &mut STREAMS[idx] {
                 let header = str_val as *mut ObjHeader;
                 if (*header).type_tag == OBJ_STRING {
                      let s_obj = str_val as *mut ObjString;
                      let data = &(*s_obj).data;
                      if s.write_all(data.as_bytes()).is_ok() {
                          return from_int(1);
                      }
                 }
             }
        }
    }
    from_int(0)
}

#[no_mangle]
pub extern "C" fn argon_socket_close(id: i64) -> i64 {
    let idx = to_int(id) as usize;
    unsafe {
        if idx < STREAMS.len() {
            let _ = STREAMS[idx].take(); 
        }
    }
    from_int(1)
}
