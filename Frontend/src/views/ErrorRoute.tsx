import { useNavigate } from 'react-router-dom';

interface ErrorRouteProps {
  message?: string;
}

export function ErrorRoute({ message }: ErrorRouteProps) {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] text-center px-4">
      <p className="text-5xl mb-4">⚠️</p>
      <h1 className="text-2xl font-semibold mb-2">Something went wrong</h1>
      {message && <p className="text-gray-500 mb-4">{message}</p>}
      <button
        onClick={() => navigate('/')}
        className="px-5 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
      >
        Go to Home
      </button>
    </div>
  );
}
