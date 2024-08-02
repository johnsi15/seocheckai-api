import express from 'express'
import cors from 'cors'
import { webScraping } from './scrapingPly.js'
import './config.js'

const app = express()
const router = express.Router()
const port = process.env.PORT || 3000

app.use(
  cors({
    origin: ['http://localhost:3000', 'https://seocheckai.com'],
    methods: ['GET', 'POST'],
  })
)

app.use(express.json())

app.get('/', (req, res) => {
  res.send('Hello World!')
})

router.use(function (req, res, next) {
  next()
})

router.post('/scraping', async (req, res) => {
  const { url } = req.body

  if (!url) {
    return res.status(400).json({
      message: 'url is required',
    })
  }

  try {
    const scrapedData = await webScraping({ url })
    res.status(200).json({
      message: 'ok',
      data: scrapedData,
    })
  } catch (error) {
    res.status(500).json({
      message: 'Error during web scraping',
      error: error.message,
    })
  }
})

app.use('/api/', router)

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
