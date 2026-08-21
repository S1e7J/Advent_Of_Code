import Control.Monad (forM_)
import Control.Monad.ST (runST)
import qualified Data.Vector.Unboxed.Mutable as V
import qualified Data.Vector.Unboxed as UV
import Data.Maybe (fromJust)

target :: Int
target = 34000000

limit :: Int
limit = 1000000

solve :: Int -> Int -> Int
solve l n_regalos = runST $ do
    houses <- V.replicate limit (0 :: Int)
    forM_ [1 .. limit - 1] $ \elf -> do
        forM_ (take l [elf, elf * 2 .. limit - 1]) $ \house -> do
            val <- V.read houses house
            V.write houses house (val + elf * n_regalos)
    frozen <- UV.unsafeFreeze houses
    return $ fromJust $ UV.findIndex (>= target) frozen

main :: IO ()
main = do
  print (solve limit 10)
  print (solve 50 11)
