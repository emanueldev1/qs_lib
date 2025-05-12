import { Component } from "react"

class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(err) {
    return { hasError: true }
  }

  componentDidCatch(error, info) {
    console.error(error, info)
    this.setState({ hasError: false })
  }

  render() {
    return this.state.hasError ? null : this.props.children
  }
}

export default ErrorBoundary
