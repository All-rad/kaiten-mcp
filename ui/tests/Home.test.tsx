import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react';
import '@testing-library/jest-dom';
import Home from '../src/pages/Home';

beforeEach(() => {
  // @ts-ignore
  global.fetch = jest.fn();
});

test('renders Russian labels and greets on success', async () => {
  // @ts-ignore
  global.fetch.mockResolvedValueOnce({ok: true, json: async () => ({message: 'Hello, Анна'})});

  render(<Home />);
  // ensure heading and button exist; prefer role query for button
  expect(screen.getByRole('heading', { name: 'Поздороваться' })).toBeInTheDocument();
  expect(screen.getByRole('button', { name: 'Поздороваться' })).toBeInTheDocument();
  expect(screen.getByLabelText('Имя:')).toBeInTheDocument();

  fireEvent.change(screen.getByLabelText('Имя:'), {target: {value: 'Анна'}});
  fireEvent.click(screen.getByRole('button', { name: 'Поздороваться' }));

  const status = await screen.findByRole('status');
  expect(status).toHaveTextContent('Hello, Анна');
});
