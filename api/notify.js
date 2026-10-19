// Envía por email el aviso de una @mención en un comentario.
// Solo lo puede llamar alguien del equipo, y solo a gente del equipo.
// Variables en Vercel: SMTP_USER (el Gmail que envía) y SMTP_PASS (contraseña de aplicación de ese Gmail).
const nodemailer = require("nodemailer");

const SUPABASE_URL = process.env.SUPABASE_URL || "https://afrcwhczpdadwwibdgxk.supabase.co";
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || require("./_anon.js");

const esc = s => String(s).replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));

module.exports = async (req, res) => {
  if (req.method !== "POST") return res.status(405).json({error: "method"});
  if (!process.env.SMTP_USER || !process.env.SMTP_PASS) return res.status(500).json({error: "smtp_not_configured"});
  const auth = req.headers.authorization || "";
  const h = {apikey: SUPABASE_ANON_KEY, Authorization: auth};

  // Quién llama (sesión de Supabase) y quién está en el equipo
  const u = await fetch(`${SUPABASE_URL}/auth/v1/user`, {headers: h});
  if (!u.ok) return res.status(401).json({error: "auth"});
  const me = String((await u.json()).email || "").toLowerCase();
  const t = await fetch(`${SUPABASE_URL}/rest/v1/team?select=email`, {headers: h});
  if (!t.ok) return res.status(403).json({error: "team"});
  const team = (await t.json()).map(r => String(r.email).toLowerCase());
  if (!team.includes(me)) return res.status(403).json({error: "not_team"});

  const b = req.body || {};
  const to = [...new Set([].concat(b.to || []).map(e => String(e).toLowerCase()))].filter(e => team.includes(e) && e !== me).slice(0, 20);
  if (!to.length) return res.status(200).json({sent: 0});
  const from = String(b.fromName || me).slice(0, 60);
  const title = String(b.title || "una tarea").slice(0, 200);
  const text = String(b.text || "").slice(0, 2000);
  const link = `https://${req.headers.host}/#item=${encodeURIComponent(String(b.item || ""))}`;

  const tx = nodemailer.createTransport({host: "smtp.gmail.com", port: 587, secure: false, auth: {user: process.env.SMTP_USER, pass: process.env.SMTP_PASS}});
  try {
    await tx.sendMail({
      from: `"Calendario PSamarán" <${process.env.SMTP_USER}>`,
      bcc: to,
      subject: `${from} te ha mencionado en «${title}»`,
      text: `${from} te ha mencionado en «${title}»:\n\n${text}\n\nÁbrelo aquí: ${link}`,
      html: `<p><b>${esc(from)}</b> te ha mencionado en «${esc(title)}»:</p><blockquote style="border-left:3px solid #ccc;margin:0;padding:4px 12px;white-space:pre-wrap">${esc(text)}</blockquote><p><a href="${esc(link)}">Abrir en el calendario</a></p>`,
    });
    return res.status(200).json({sent: to.length});
  } catch (e) {
    console.error(e);
    return res.status(502).json({error: "smtp"});
  }
};
