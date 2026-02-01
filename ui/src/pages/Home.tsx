import React, {useState} from 'react';

export default function Home() {
  const [name, setName] = useState('');
  const [result, setResult] = useState('');
  const [error, setError] = useState('');

  const onGreet = async () => {
    setResult(''); setError('');
    try {
      const res = await fetch(`/hello/${encodeURIComponent(name)}`);
      if (!res.ok) {
        const err = await res.json();
        setError(err.error || 'Ошибка');
        return;
      }
      const body = await res.json();
      setResult(body.message);
    } catch (e) {
      setError('Сервер недоступен');
    }
  };

  return (
    <div>
      <h1>Поздороваться</h1>
      <label htmlFor="name">Имя:</label>
      <input id="name" value={name} onChange={e => setName(e.target.value)} />
      <button onClick={onGreet}>Поздороваться</button>

      {result && <div role="status">{result}</div>}
      {error && <div role="alert">{error}</div>}
    </div>
  );
}
