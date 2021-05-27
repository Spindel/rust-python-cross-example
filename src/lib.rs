use pyo3::prelude::*;
use pyo3::wrap_pyfunction;

#[pyfunction]
fn spid_42() -> PyResult<String> {
    let res: String = "42".to_string();
    Ok(res)
}

#[pymodule]
fn lib_spid_test(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(spid_42, m)?)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
