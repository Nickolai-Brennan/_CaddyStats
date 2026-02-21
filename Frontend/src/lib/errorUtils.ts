import { useCallback } from 'react';
import { useToast } from '../app/providers/ToastProvider';

export interface NormalizedError {
  message: string;
  status?: number;
  code?: string;
}

export function normalizeError(err: unknown): NormalizedError {
  if (err instanceof Error) {
    // graphql-request wraps HTTP errors; check for status
    const anyErr = err as Error & { response?: { status?: number; errors?: Array<{ message: string; extensions?: { code?: string } }> } };
    if (anyErr.response) {
      const firstGqlError = anyErr.response.errors?.[0];
      return {
        message: firstGqlError?.message ?? err.message,
        status: anyErr.response.status,
        code: firstGqlError?.extensions?.code,
      };
    }
    return { message: err.message };
  }
  if (typeof err === 'string') return { message: err };
  return { message: 'An unexpected error occurred.' };
}

export function isNetworkError(err: unknown): boolean {
  if (err instanceof TypeError && err.message.toLowerCase().includes('fetch')) return true;
  if (err instanceof Error) {
    const anyErr = err as Error & { response?: { status?: number } };
    const status = anyErr.response?.status;
    return status === undefined || status === 0 || status >= 500;
  }
  return false;
}

export function useErrorToast() {
  const { addToast } = useToast();

  return useCallback(
    (err: unknown) => {
      const { message } = normalizeError(err);
      addToast(message, 'error');
    },
    [addToast],
  );
}
