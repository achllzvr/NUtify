interface Props {
    year: number;
    currentYear: number;
    minYear: number | null;
    maxYear: number | null;
    clickYear: (data: number) => void;
}
declare const Years: (props: Props) => import("react/jsx-runtime").JSX.Element;
export default Years;
