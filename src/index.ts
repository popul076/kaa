import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => {
  return c.html(HTML_CONTENT)
})

export default app
