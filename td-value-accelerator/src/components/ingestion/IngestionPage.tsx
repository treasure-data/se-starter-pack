export function IngestionPage() {
  return (
    <div className="h-full w-full flex flex-col">
      <div className="p-6 border-b bg-white">
        <h1 className="text-2xl font-semibold text-slate-900">Data Ingestion</h1>
        <p className="text-sm text-slate-600 mt-1">Configure and manage data ingestion workflows</p>
      </div>
      
      <div className="flex-1 bg-slate-50">
        <iframe
          src="https://udify.app/chatbot/f8eCoaWwjE6AMogz"
          style={{ width: '100%', height: '100%', minHeight: '700px' }}
          frameBorder="0"
          allow="microphone"
        />
      </div>
    </div>
  );
}