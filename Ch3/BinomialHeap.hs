{-# LANGUAGE InstanceSigs #-}

module BinomialHeap 
( BinomialHeap
) where

  import Heap

  data Tree a = NODE Int a [Tree a]
  newtype BinomialHeap a = BH [Tree a]

  rank :: Tree a -> Int
  rank (NODE r _ _) = r

  root :: Tree a -> a
  root (NODE _ x _) = x

  link :: Ord a => Tree a -> Tree a -> Tree a
  link t1@(NODE r x1 c1) t2@(NODE _ x2 _) = if x1 < x2 
                                             then NODE (r + 1) x1 (t2 : c1)
                                             else NODE (r + 1) x2 (t1 : c1)

  insTree :: Ord a => Tree a -> [Tree a] -> [Tree a]
  insTree t [] = [t]
  insTree t ts@(t' : ts') = if rank t < rank t'
                            then t : ts
                            else insTree (link t t') ts'

  mrg :: Ord a => [Tree a] -> [Tree a] -> [Tree a]
  mrg ts1 [] = ts1
  mrg [] ts2 = ts2
  mrg ts1@(t1 : ts1') ts2@(t2 : ts2')
    | rank t1 < rank t2 = t1 : mrg ts1' ts2
    | rank t2 < rank t1 = t2 : mrg ts1 ts2'
    | otherwise = insTree (link t1 t2) (mrg ts1' ts2')

  removeMinTree :: Ord a => [Tree a] -> (Tree a, [Tree a])
  removeMinTree [] = error "empty heap"
  removeMinTree [t] = (t, [])
  removeMinTree (t : ts) = if root t < root t' then (t , ts) else (t' , t : ts')
      where (t' , ts') = removeMinTree ts

  instance Heap BinomialHeap where
    empty = BH []
    isEmpty (BH ts) = null ts

    insert x (BH ts) = BH (insTree (NODE 0 x []) ts)
    merge (BH ts1) (BH ts2) = BH (mrg ts1 ts2)

    findMin (BH ts) = root t
      where (t , _) = removeMinTree ts

    deleteMin (BH ts) = BH (mrg (reverse ts1) ts2)
      where (NODE _ _ ts1 , ts2) = removeMinTree ts
