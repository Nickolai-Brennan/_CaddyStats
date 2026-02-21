import { useState, useMemo } from 'react';
import { Link } from 'react-router-dom';
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  createColumnHelper,
  type SortingState,
} from '@tanstack/react-table';
import { SeoHead } from '../../design-system/seo/SeoHead';
import { Input } from '../../design-system/primitives/Input';
import { Button } from '../../design-system/primitives/Button';
import { SkeletonCard } from '../../design-system/primitives/Skeleton';
import { EmptyState } from '../../design-system/primitives/EmptyState';
import { ErrorState } from '../../design-system/primitives/ErrorState';
import { usePosts } from '../../hooks/usePosts';
import { STUB_POST_LIST } from '../../lib/stubData';
import { formatDate } from '../../utils/formatters';
import type { PostListItem } from '../../types/post';

const columnHelper = createColumnHelper<PostListItem>();

const columns = [
  columnHelper.accessor('title', {
    header: 'Title',
    cell: (info) => (
      <Link
        to={`/post/${info.row.original.slug}`}
        className="font-medium text-green-600 dark:text-green-400 hover:underline line-clamp-2"
      >
        {info.getValue()}
      </Link>
    ),
  }),
  columnHelper.accessor('publishedAt', {
    header: 'Date',
    cell: (info) => {
      const val = info.getValue();
      return val ? formatDate(val) : '—';
    },
  }),
];

const MS_PER_DAY = 86_400_000;



export function ArchiveView() {
  const { data, isLoading, isError, refetch } = usePosts(50);
  const [sorting, setSorting] = useState<SortingState>([]);
  const [globalFilter, setGlobalFilter] = useState('');

  const tableData = useMemo<PostListItem[]>(() => {
    if (data && data.length > 0) return data;
    return STUB_POST_LIST;
  }, [data]);

  const table = useReactTable({
    data: tableData,
    columns,
    state: { sorting, globalFilter },
    onSortingChange: setSorting,
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    initialState: { pagination: { pageSize: 20 } },
  });

  return (
    <>
      <SeoHead title="Archive | Caddy Stats" description="Browse all golf articles, analytics, and tournament coverage." />
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-gray-100 mb-6">Archive</h1>

        <div className="mb-4">
          <Input
            placeholder="Search articles…"
            value={globalFilter}
            onChange={(e) => setGlobalFilter(e.target.value)}
            className="max-w-xs"
          />
        </div>

        {isLoading ? (
          <div className="space-y-3">
            {[1, 2, 3, 4, 5].map((i) => <SkeletonCard key={i} />)}
          </div>
        ) : isError ? (
          <ErrorState
            title="Could not load archive"
            description="The content server may be offline."
            onRetry={() => { void refetch(); }}
          />
        ) : tableData.length === 0 ? (
          <EmptyState title="No articles found" description="Try adjusting your search." />
        ) : (
          <>
            <div className="overflow-x-auto rounded-xl border border-gray-200 dark:border-gray-700">
              <table className="w-full text-sm">
                <thead className="bg-gray-50 dark:bg-gray-800 text-gray-600 dark:text-gray-400">
                  {table.getHeaderGroups().map((headerGroup) => (
                    <tr key={headerGroup.id}>
                      {headerGroup.headers.map((header) => (
                        <th
                          key={header.id}
                          className="px-4 py-3 text-left font-semibold cursor-pointer select-none"
                          onClick={header.column.getToggleSortingHandler()}
                        >
                          {header.isPlaceholder ? null : (
                            <span className="flex items-center gap-1">
                              {String(header.column.columnDef.header ?? '')}
                              {header.column.getIsSorted() === 'asc' ? ' ↑' : header.column.getIsSorted() === 'desc' ? ' ↓' : ''}
                            </span>
                          )}
                        </th>
                      ))}
                    </tr>
                  ))}
                </thead>
                <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                  {table.getRowModel().rows.map((row) => (
                    <tr key={row.id} className="bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors">
                      {row.getVisibleCells().map((cell) => (
                        <td key={cell.id} className="px-4 py-3">
                          {cell.renderValue() as React.ReactNode}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            <div className="mt-4 flex items-center justify-between gap-4 text-sm text-gray-600 dark:text-gray-400">
              <span>
                Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}
              </span>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => table.previousPage()}
                  disabled={!table.getCanPreviousPage()}
                >
                  Previous
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => table.nextPage()}
                  disabled={!table.getCanNextPage()}
                >
                  Next
                </Button>
              </div>
            </div>
          </>
        )}
      </div>
    </>
  );
}
