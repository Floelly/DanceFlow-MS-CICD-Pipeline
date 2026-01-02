import { render, screen } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import Button from './Button'

describe('Button component', () => {
  it('renders children text', () => {
    render(<Button text="Click me" onClick={() => {}} />)
    expect(screen.getByRole('button')).toHaveTextContent('Click me')
  })
})