pub fn greet(name: String) -> String {
    match name.as_str() {
        "" => "Hello unknown!".to_string(),
        _ => format!("Hello, {}!", name)

    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_greet() {
        assert_eq!("Hello, world!", super::greet("world".to_string()));
    }

    #[test]
    fn test_greet_with_empty_string() {
        assert_eq!("Hello unknown!", super::greet("".to_string()));
    
    }
}
