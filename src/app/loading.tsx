export default function Loading() {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in">
      <div className="text-center py-12">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-ops-accent"></div>
        <p className="text-ops-text-dim text-sm mt-4 font-mono">Loading...</p>
      </div>
    </div>
  );
}
