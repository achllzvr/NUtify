import React, { useEffect, useRef, useState } from "react";
import "../styles/footer.css";
import AOS from "aos";
import "aos/dist/aos.css";

const Footer = () => {
  const [showModal, setShowModal] = useState(false);
  const [progress, setProgress] = useState(0);
  const [downloading, setDownloading] = useState(false);
  const [error, setError] = useState("");
  const [received, setReceived] = useState(0);
  const [total, setTotal] = useState(0);
  const [speed, setSpeed] = useState(0); // bytes/sec
  const [done, setDone] = useState(false);
  const controllerRef = useRef(null);
  const startedAtRef = useRef(0);

  // Put your APK under public/android/app-release.apk
  // Served by Vite at /android/app-release.apk
  const APK_PATH = "/android/app-release.apk";

  useEffect(() => {
    AOS.init({ duration: 500, easing: "ease-out", once: true });
    const onLoad = () => AOS.refresh();
    window.addEventListener("load", onLoad);
    return () => window.removeEventListener("load", onLoad);
  }, []);

  const resetState = () => {
    setProgress(0); setError(""); setReceived(0); setTotal(0); setSpeed(0); setDone(false);
  };
  const closeModal = () => { if (!downloading) { setShowModal(false); resetState(); } };

  const startDownload = async () => {
    setShowModal(true); resetState(); setDownloading(true);
    const controller = new AbortController();
    controllerRef.current = controller;
    startedAtRef.current = performance.now();
    try {
      const res = await fetch(APK_PATH, { signal: controller.signal });
      if (!res.ok) throw new Error(`Download failed (${res.status})`);

      const contentLength = Number(res.headers.get("content-length")) || 0;
      setTotal(contentLength);
      const reader = res.body?.getReader();
      if (!reader) {
        // Fallback: stream not available
        window.location.href = APK_PATH;
        setDownloading(false);
        setDone(true);
        return;
      }

      const chunks = [];
      let acc = 0;
      let lastTickTime = startedAtRef.current;
      let lastTickBytes = 0;

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        chunks.push(value);
        acc += value.length;
        setReceived(acc);
        if (contentLength > 0) setProgress(Math.min(100, Math.round((acc / contentLength) * 100)));
        const now = performance.now();
        const dt = (now - lastTickTime) / 1000;
        if (dt >= 0.25) {
          const deltaBytes = acc - lastTickBytes;
          setSpeed(deltaBytes / dt); // bytes/sec
          lastTickTime = now; lastTickBytes = acc;
        }
      }

      // Finish
      setProgress(100); setSpeed(0); setDone(true);
      const blob = new Blob(chunks, { type: "application/vnd.android.package-archive" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a"); a.href = url; a.download = "NUtify.apk";
      document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
    } catch (e) {
      if (e.name !== 'AbortError') setError(e.message || "Download failed");
    } finally {
      setDownloading(false);
    }
  };

  const cancelDownload = () => {
    try { controllerRef.current?.abort(); } catch { /* no-op */ }
    setDownloading(false); setError("Cancelled");
  };

  const fmtBytes = (b) => {
    if (!b && b !== 0) return '';
    const units = ['B','KB','MB','GB'];
    let i = 0; let val = b;
    while (val >= 1024 && i < units.length-1) { val /= 1024; i++; }
    return `${val.toFixed(val < 10 && i > 0 ? 1 : 0)} ${units[i]}`;
  };
  const fmtSpeed = (bps) => bps ? `${fmtBytes(bps)}/s` : '';
  const eta = () => {
    if (speed > 0 && total > 0 && received >= 0) {
      const remain = total - received;
      const sec = remain / speed;
      if (!isFinite(sec) || sec < 0) return '';
      const m = Math.floor(sec / 60); const s = Math.round(sec % 60);
      return `${m > 0 ? m+ 'm ' : ''}${s}s`;
    }
    return '';
  };

  const DownloadModal = () => (
    <div className="download-modal-overlay" role="dialog" aria-modal="true">
      <div className="download-modal">
        <div className="dm-title">Android APK Download</div>
        <div className="dm-sub">File: NUtify.apk</div>

        {error ? (
          <div className="dm-state dm-error">{error}</div>
        ) : done ? (
          <div className="dm-state dm-success">Download complete</div>
        ) : null}

        {!error && (
          <>
            <div className={`progress-bar ${total === 0 ? 'indeterminate' : ''}`}>
              <div className="progress-bar-inner" style={{ width: `${progress}%` }} />
            </div>
            <div className="metrics">
              <span>{fmtBytes(received)}{total ? ` / ${fmtBytes(total)}` : ''}</span>
              <span>{total ? `${progress}%` : '...'}</span>
              <span>{fmtSpeed(speed)}{eta() ? ` • ${eta()} ETA` : ''}</span>
            </div>
          </>
        )}

        <div className="download-actions">
          {downloading ? (
            <button className="btn-cancel" onClick={cancelDownload}>Cancel</button>
          ) : error ? (
            <button className="btn-primary" onClick={startDownload}>Retry</button>
          ) : (
            <button className="btn-primary" onClick={closeModal}>Close</button>
          )}
        </div>
      </div>
      <style>{`
        .download-modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.35); display: flex; align-items: center; justify-content: center; z-index: 1000; }
        .download-modal { background: #fff; border-radius: 16px; padding: 18px 18px 14px; width: min(92vw, 460px); box-shadow: 0 18px 40px rgba(0,0,0,.18); }
        .dm-title { font-weight: 800; color: #2d3748; font-size: 1.1rem; }
        .dm-sub { color: #6b7280; font-size: .9rem; margin-bottom: 10px; }
        .dm-state { margin: 8px 0; font-weight: 700; }
        .dm-success { color: #0f766e; }
        .dm-error { color: #b91c1c; }
        .progress-bar { height: 12px; background: #f1f2f4; border-radius: 9999px; overflow: hidden; margin: 12px 0; position: relative; }
        .progress-bar-inner { height: 100%; background: #ffd36b; transition: width .2s ease; }
        .progress-bar.indeterminate .progress-bar-inner { position: absolute; width: 40%; left: -40%; animation: indet 1.4s infinite; }
        @keyframes indet { 0% { left: -40%; } 50% { left: 60%; } 100% { left: 100%; } }
        .metrics { display: flex; justify-content: space-between; font-size: .85rem; color: #47505B; }
        .download-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 12px; }
        .btn-cancel, .btn-primary { border: none; border-radius: 10px; padding: 8px 14px; font-weight: 700; cursor: pointer; }
        .btn-cancel { background: #e5e7eb; color: #374151; }
        .btn-primary { background: #ffd36b; color: #7a5c00; }
      `}</style>
    </div>
  );
  return (
    <footer className="footer-section">
      <div className="footer-content">
        <h2 className="footer-title" data-aos="fade-up">
          Ready to Simplify Your Academic Life?
        </h2>
        <div data-aos="fade-up" data-aos-delay="150">
        <p className="footer-desc" >
          Download Nutify today to reclaim your time, streamline student
          interactions, and make appointment management effortless. Take control
          of your schedule and stay connected like never before.
        </p>
        <div className="footer-download-buttons">
          <button type="button" className="footer-cta-btn footer-cta-btn--android" onClick={startDownload}>
            Download for Android
          </button>
          <button type="button" className="footer-cta-btn footer-cta-btn--ios" disabled>
            IOS - Under Development
          </button>
        </div>
        </div>
      </div>
      {showModal && <DownloadModal />}
    </footer>
  );
};

export default Footer;
